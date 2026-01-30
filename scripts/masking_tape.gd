class_name MaskingTape extends CharacterBody2D

@export_range(0.0, 1000.0, 10.0) var roll_acceleration  : float
@export_range(0.0, 100.0, 1.0)   var deceleration_scale : float
@export_range(0.0, 1000.0, 10.0) var jump_speed         : float
@export_range(0.0, 1000.0, 10.0) var reroll_speed       : float
@export_range(0.0, 1.0, 0.001) var espilon_ungrip       : float
@export var _masking_rubber : Line2D

var _in_free_fall   : bool
var _is_rerolling   : bool

func _ready() -> void :
	_masking_rubber.add_point(self.position)
	_in_free_fall = not is_on_floor()
	_is_rerolling = Input.is_action_just_pressed('move_tape_reroll')

func _physics_process(delta : float) -> void :
	velocity.y += 980 * delta
	get_input(delta)

	if not _is_rerolling :
		move_and_slide()

		if _in_free_fall and is_on_floor() :
			_in_free_fall = false
			_masking_rubber.add_point(self.position)
		elif not is_on_floor() and not _in_free_fall :
			_in_free_fall = true

	elif _masking_rubber.get_point_count() > 1 :
		self.position = self.position.move_toward(_masking_rubber.get_point_position(_masking_rubber.get_point_count()-2), reroll_speed*delta)
		if self.position.distance_to(_masking_rubber.get_point_position(_masking_rubber.get_point_count()-2)) < espilon_ungrip :
			_masking_rubber.remove_point(_masking_rubber.get_point_count()-2)

	_masking_rubber.set_point_position(_masking_rubber.get_point_count()-1, self.position)

func get_input(delta : float) -> void :
	_is_rerolling = Input.is_action_pressed('move_tape_reroll')

	if _is_rerolling :
		velocity = Vector2.ZERO
		return
	
	var right  = Input.is_action_pressed('move_tape_right')
	var left   = Input.is_action_pressed('move_tape_left')
	var jump   = Input.is_action_just_pressed('move_tape_jump')

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
