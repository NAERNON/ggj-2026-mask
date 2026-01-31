class_name MaskingTape extends CharacterBody2D

@export_range(0.0, 1000.0, 10.0) var roll_acceleration  : float
@export_range(0.0, 100.0, 1.0)   var deceleration_scale : float
@export_range(0.0, 1000.0, 10.0) var jump_speed         : float
@export_range(0.0, 1000.0, 10.0) var reroll_speed       : float

@export var contact_floor : Node2D
var reroll_target     : Vector2

signal start_grip()
signal end_grip()
signal touch_or_leave_floor()
signal reroll()

var _in_free_fall   : bool :
	set(new_value) :
		_in_free_fall = new_value
		touch_or_leave_floor.emit()

var _is_rerolling : bool

var is_gripping  : bool :
	set(new_value) :
		is_gripping = new_value
		if is_gripping :
			start_grip.emit()
		else :
			end_grip.emit()

func _ready() -> void :
	_in_free_fall = not is_on_floor()
	_is_rerolling = Input.is_action_just_pressed('move_tape_reroll')

func _physics_process(delta : float) -> void :
	velocity.y += 980 * delta
	get_input(delta)

	if not _is_rerolling :
		move_and_slide()

		if _in_free_fall and is_on_floor() :
			_in_free_fall = false
		elif not is_on_floor() and not _in_free_fall :
			_in_free_fall = true
	
	else :
		if reroll_target != Vector2.INF :
			self.position = self.position.move_toward(reroll_target, reroll_speed*delta)
			reroll.emit()
		

func get_input(delta : float) -> void :
	_is_rerolling = Input.is_action_pressed('move_tape_reroll') and is_gripping

	if _is_rerolling :
		velocity = Vector2.ZERO
		return
	
	var right  = Input.is_action_pressed('move_tape_right')
	var left   = Input.is_action_pressed('move_tape_left')
	var jump   = Input.is_action_just_pressed('move_tape_jump')
	var grip   = Input.is_action_just_pressed('tape_switch_grip')

	if grip :
		is_gripping = not is_gripping

	var moving = right or left

	if is_on_floor() and jump :
		velocity.y = -jump_speed

	if not moving :
		if is_on_floor() :
			velocity.x = move_toward(velocity.x, 0.0, deceleration_scale)
	else :
		if right:
			velocity.x += roll_acceleration * delta
		if left:
			velocity.x -= roll_acceleration * delta
