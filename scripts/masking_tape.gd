class_name MaskingTape extends CharacterBody2D

@export_range(0.0, 1000.0, 10.0) var roll_acceleration  : float
@export_range(0.0, 100.0, 1.0)   var deceleration_scale : float
@export_range(0.0, 1000.0, 10.0) var jump_speed         : float
@export var _masking_rubber : Line2D

var _in_free_fall   : bool

func _ready() -> void :
	_masking_rubber.add_point(self.position)
	_in_free_fall = not is_on_floor()

func _physics_process(delta : float) -> void :
	velocity.y += 980 * delta
	get_input(delta)
	move_and_slide()

	if _in_free_fall and is_on_floor() :
		_in_free_fall = false
		_masking_rubber.add_point(self.position)
	elif not is_on_floor() and not _in_free_fall :
		_in_free_fall = true

	_masking_rubber.set_point_position(_masking_rubber.get_point_count()-1, self.position)

func get_input(delta : float) :
	var right = Input.is_action_pressed('move_tape_right')
	var left = Input.is_action_pressed('move_tape_left')
	var jump = Input.is_action_just_pressed('move_tape_jump')

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
