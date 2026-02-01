class_name MaskingTape extends CharacterBody2D

@export_range(0.0, 1000.0, 10.0) var initial_tape_dist  : float
@export_range(0.0, 1000.0, 10.0) var roll_acceleration  : float
@export_range(0.0, 100.0, 1.0)   var deceleration_scale : float
@export_range(0.0, 1000.0, 10.0) var jump_speed         : float
@export_range(0.0, 1000.0, 10.0) var reroll_speed       : float
@export_range(0.0, 1000.0, 10.0) var wall_roll_speed    : float
@export_range(0.0, 10.0, 1.0) var push_force         : float

@export var contact_floor : Node2D
@export var face_sprite   : CharacterFaceSprite

var reroll_target     : Vector2

var _tape_len      : float
var _used_tape_len : float

var _grip_on_wall : bool :
	set(new_value) :
		_grip_on_wall = new_value
		floor_stop_on_slope = not floor_stop_on_slope
		if _grip_on_wall :
			if get_wall_normal().x == 1 :
				contact_floor.position.x = -21
			elif get_wall_normal().x == -1 :
				contact_floor.position.x = 21
			contact_floor.position.y = 0
			velocity = Vector2.ZERO

		touch_or_leave_wall.emit()

signal start_grip()
signal end_grip()
signal touch_or_leave_floor()
signal touch_or_leave_wall()
signal reroll()
signal touch_restock()

var _in_free_fall   : bool :
	set(new_value) :
		_in_free_fall = new_value
		if is_on_floor() :
			contact_floor.position.y = 21
			contact_floor.position.x = 0
		touch_or_leave_floor.emit()

var _is_rerolling : bool

var is_gripping  : bool :
	set(new_value) :
		is_gripping = new_value
		if is_gripping :
			start_grip.emit()
		else :
			end_grip.emit()
			_grip_on_wall  = false
			one_grip_point = false

var one_grip_point : bool

var last_floor_position : Vector2

func _ready() -> void :
	_in_free_fall = not is_on_floor()
	_is_rerolling = Input.is_action_just_pressed('move_tape_reroll')
	_tape_len     = initial_tape_dist

func _physics_process(delta : float) -> void :
	get_input(delta)

	if not _is_rerolling :
		if not _grip_on_wall :
			velocity.y += 980 * delta

		if is_on_floor() :
			last_floor_position = contact_floor.global_position

		move_and_slide()
		if is_on_wall() and is_gripping :
			if not _grip_on_wall :
				_grip_on_wall = true

		elif _grip_on_wall and not is_on_wall() :
				_grip_on_wall = false

		if _in_free_fall and is_on_floor() :
			_in_free_fall = false
		elif not is_on_floor() and not _in_free_fall :
			_in_free_fall = true
		
		for collision_id : int in range(get_slide_collision_count()) :
			var collision : KinematicCollision2D = get_slide_collision(collision_id)
			if collision.get_collider() is RigidBody2D :
				var box : RigidBody2D = collision.get_collider()
				box.apply_force(collision.get_normal() * -push_force)
			elif collision.get_collider() is StaticBody2D :
				var static_body : StaticBody2D = collision.get_collider()
				if static_body.get_collision_layer_value(2) :
					touch_restock.emit()
	else :
		if reroll_target != Vector2.INF :
			self.position = self.position.move_toward(reroll_target, reroll_speed*delta)
			reroll.emit()
	
	if velocity == Vector2.ZERO :
		if face_sprite.get_state() > CharacterFaceSprite.State.SLEEP_002 :
			face_sprite.set_state(CharacterFaceSprite.State.IDLE)
	else :
		if velocity.x > 0 :
			if velocity.x < 300 :
				face_sprite.set_state(CharacterFaceSprite.State.RUN_SLOW_RIGHT)
			else :
				face_sprite.set_state(CharacterFaceSprite.State.RUN_FAST_RIGHT)
		else :
			if velocity.x > -300 :
				face_sprite.set_state(CharacterFaceSprite.State.RUN_SLOW_LEFT)
			else :
				face_sprite.set_state(CharacterFaceSprite.State.RUN_FAST_LEFT)

func get_input(delta : float) -> void :
	_is_rerolling = Input.is_action_pressed('move_tape_reroll') and is_gripping

	if _is_rerolling :
		velocity = Vector2.ZERO
		return
	
	var jump  = Input.is_action_just_pressed('move_tape_jump')
	var grip  = Input.is_action_just_pressed('tape_switch_grip')
	
	if grip :
		if not is_gripping or (is_gripping and (is_on_wall() or is_on_floor())):
			if is_on_wall() and not _grip_on_wall :
				_grip_on_wall = true
			is_gripping = not is_gripping

	if _grip_on_wall :
		velocity = Vector2.ZERO
		var up = Input.is_action_pressed("move_tape_up")
		var down = Input.is_action_pressed("move_tape_down")

		if up :
			velocity.y = -wall_roll_speed
		elif down :
			velocity.y = wall_roll_speed

		if _used_tape_len >= _tape_len and one_grip_point :
			velocity = Vector2.ZERO
		return

	var right = Input.is_action_pressed('move_tape_right')
	var left  = Input.is_action_pressed('move_tape_left')

	var moving : bool = right or left
	if is_on_floor() and jump :
		velocity.y = -jump_speed

	if not moving :
		if is_on_floor() :
			velocity.x = move_toward(velocity.x, 0.0, deceleration_scale)
	else :
		if right:
			if velocity.x < 0 :
				velocity.x += roll_acceleration * delta * 5
			else :
				velocity.x += roll_acceleration * delta
		if left:
			if velocity.x > 0 :
				velocity.x -= roll_acceleration * delta * 5
			else :
				velocity.x -= roll_acceleration * delta
	
	if is_gripping and _used_tape_len >= _tape_len and one_grip_point :
		velocity.x = 0.0
		if velocity.y < 0.0 :
			velocity.y = 0.0

func update_used_tape_len(used_tape : float) -> void :
	_used_tape_len = used_tape

func add_max_tape(tape_restock : float) -> void :
	_tape_len += tape_restock
