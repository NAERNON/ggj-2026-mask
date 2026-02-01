extends Node2D

@export var masking_tape : MaskingTape
@export_range(0.0, 1.0, 0.01) var epsilon_tape : float
@export_range(1.0, 5.0, 0.01) var epsilon_corner : float

@export_range(0.0, 5.0, 0.1) var rubber_width : float

@export var platforms : Node
@export var restock   : StaticBody2D
@export_range(0.0, 1000.0, 10.0) var restock_value : float

@export var roll_frame : AnimatedSprite2D
@export var paint      : AnimatedSprite2D
@export var victory_dance : AnimatedSprite2D

@export var menu_music    : AudioStreamPlayer
@export var main_music    : AudioStreamPlayer
@export var rip_scotch    : AudioStreamPlayer
@export var unroll_scotch : AudioStreamPlayer
@export var victory_music : AudioStreamPlayer
@export var start_menu    : StartMenu
@export var pause_menu    : PauseMenu

var _masking_tapes : Array[Line2D]
var _masking_tapes_len : float

var _current_tape : Line2D
var _nb_current_tape_points : int
var _current_tape_len : float

var _platform_corners : Array[Vector2]

var _victory_timer: Timer = Timer.new()


func _ready() -> void :
	add_child(_victory_timer)
	_victory_timer.one_shot = true
	_victory_timer.timeout.connect(_on_victory_timer_timeout)
	
	for child_idx : int in platforms.get_child_count() :
		var platform : StaticBody2D = platforms.get_child(child_idx)
		var center : Vector2 = platform.position

		var collision : CollisionShape2D = platform.get_child(0)
		var rectangle : RectangleShape2D = collision.shape
		var size : Vector2 = rectangle.size * platform.scale / 2.0

		_platform_corners.append(center + Vector2(-size.x, size.y))
		_platform_corners.append(center + Vector2(size.x, size.y))
		_platform_corners.append(center + Vector2(size.x, -size.y))
		_platform_corners.append(center + Vector2(-size.x, -size.y))

		_current_tape_len = 0.0
		_masking_tapes_len = 0.0
		
		masking_tape.process_mode = Node.PROCESS_MODE_DISABLED

func _physics_process(_delta : float) -> void :
	if _current_tape :
		_current_tape.set_point_position(_nb_current_tape_points-1, masking_tape.contact_floor.global_position)
		
		if _nb_current_tape_points > 1 :
			var p1 : Vector2 = _current_tape.get_point_position(_nb_current_tape_points-2)
			var p2 : Vector2 = _current_tape.get_point_position(_nb_current_tape_points-1)

			var param_d : Vector3 = get_param_d(p1, p2)
			var a : float = param_d.x*param_d.x + param_d.y*param_d.y

			for corner : Vector2 in _platform_corners :
				var alpha : float = (-param_d.z-param_d.x*corner.x - param_d.y*corner.y) / a
				var dist  : float = abs(alpha) * sqrt(a)

				var p_on_d : Vector2 = corner + alpha*Vector2(param_d.x, param_d.y)

				var p1_p2 = p1.distance_to(p2)
				var p_p1  = p_on_d.distance_to(p1)
				var p_p2  = p_on_d.distance_to(p2)

				if dist < epsilon_corner and p_p1 < p1_p2 and p_p2 < p1_p2 :
					add_tape_point(corner, _nb_current_tape_points-1)
					p1 = _current_tape.get_point_position(_nb_current_tape_points-2)
					p2 = _current_tape.get_point_position(_nb_current_tape_points-1)
		
			masking_tape.update_used_tape_len(_current_tape_len + p1.distance_to(p2) + _masking_tapes_len)

		else :
			masking_tape.update_used_tape_len(_masking_tapes_len)	

func get_param_d(p1 : Vector2, p2 : Vector2) -> Vector3 :
		var param_d : Vector3

		param_d.x = -p1.y + p2.y
		param_d.y = p1.x - p2.x
		param_d.z = -param_d.x * p1.x - param_d.y * p1.y

		return param_d

func add_tape_point(pos : Vector2, index : int = -1) -> void :
	if not masking_tape._is_rerolling :
		if masking_tape.get_slide_collision_count() > 0 :
			var t : KinematicCollision2D = masking_tape.get_slide_collision(0)
			_current_tape.add_point(t.get_position(), index)
		else :
			_current_tape.add_point(pos, index)
		_nb_current_tape_points += 1

		if _nb_current_tape_points > 1 :
			masking_tape.one_grip_point = true

		if _current_tape.get_child_count(false) > 0 :
			var foo : StaticBody2D = _current_tape.get_child(-1)
			foo.set_collision_layer_value(1, true)

		if _nb_current_tape_points > 2 :
			var p1 : Vector2 = _current_tape.get_point_position(_nb_current_tape_points-3)
			var p2 : Vector2 = _current_tape.get_point_position(_nb_current_tape_points-2)
			_current_tape_len += p1.distance_to(p2)
			var center = (p1 + p2) / 2
			var angle : float = p1.angle_to_point(p2)
			var size : float = p1.distance_to(p2)

			var rectangle : RectangleShape2D = RectangleShape2D.new()
			rectangle.size = Vector2(size, rubber_width)

			var collision : CollisionShape2D = CollisionShape2D.new()
			collision.shape = rectangle

			var body : StaticBody2D = StaticBody2D.new()
			body.rotation = angle
			body.position = center
			body.add_child(collision)

			body.set_collision_layer_value(1, false)
			_current_tape.add_child(body)

func remove_tape_point() -> void :
	if _nb_current_tape_points > 2 :
		var p1 : Vector2 = _current_tape.get_point_position(_nb_current_tape_points-2)
		var p2 : Vector2 = _current_tape.get_point_position(_nb_current_tape_points-3)
		_current_tape_len -= p1.distance_to(p2)

	_current_tape.remove_point(_nb_current_tape_points-2)
	_nb_current_tape_points -= 1

	if _nb_current_tape_points > 1 :
		var body : Node = _current_tape.get_child(-1)
		_current_tape.remove_child(body)
	elif _nb_current_tape_points == 0 :
		masking_tape.one_grip_point = false

func _on_masking_tape_end_grip() -> void:
	if _current_tape :
		_masking_tapes.append(_current_tape)
		_masking_tapes_len += _current_tape_len
		if _nb_current_tape_points > 1 :
			var p1 : Vector2 = _current_tape.get_point_position(_nb_current_tape_points-2)
			var p2 : Vector2 = _current_tape.get_point_position(_nb_current_tape_points-1)
			_masking_tapes_len += p1.distance_to(p2)
		if _current_tape.get_child_count(false) > 0 :
			var foo : StaticBody2D = _current_tape.get_child(-1)
			foo.set_collision_layer_value(1, true)

	_current_tape_len = 0.0
	_current_tape = null
	rip_scotch.play(0.22)
	unroll_scotch.stop()

func _on_masking_tape_start_grip() -> void:
	_current_tape = Line2D.new()
	_current_tape.default_color = Color.from_string("ffeca2", Color.WHITE)
	self.add_child(_current_tape)
	_current_tape.width = 2.5
	_nb_current_tape_points = 0
	_current_tape_len = 0.0
	masking_tape.reroll_target = Vector2.INF

	add_tape_point(masking_tape.contact_floor.global_position)

	if masking_tape.is_on_wall() or masking_tape.is_on_floor() :
		masking_tape.reroll_target = _current_tape.get_point_position(_nb_current_tape_points-1) - masking_tape.contact_floor.position * masking_tape.scale
		add_tape_point(masking_tape.contact_floor.global_position)
	
	unroll_scotch.play()

func _on_masking_tape_touch_or_leave_floor() -> void:
	if _current_tape and not masking_tape._is_rerolling:
		if masking_tape.is_on_floor() :
			_current_tape.set_point_position(_nb_current_tape_points-1, masking_tape.contact_floor.global_position)
		masking_tape.reroll_target = _current_tape.get_point_position(_nb_current_tape_points-1) - masking_tape.contact_floor.position * masking_tape.scale
		add_tape_point(masking_tape.contact_floor.global_position)

func _on_masking_tape_reroll() -> void:
	if masking_tape.position.distance_to(masking_tape.reroll_target) < epsilon_tape :
		remove_tape_point()

		if _nb_current_tape_points < 2 :
			masking_tape.reroll_target = Vector2.INF
			masking_tape.is_gripping = false
		else :
			masking_tape.reroll_target = _current_tape.get_point_position(_nb_current_tape_points-2) - masking_tape.contact_floor.position * masking_tape.scale

func _on_masking_tape_touch_restock() -> void:
	self.remove_child(restock)
	masking_tape.add_max_tape(restock_value)


func _on_masking_tape_touch_or_leave_wall() -> void:
	if _current_tape and not masking_tape._is_rerolling :
		_current_tape.set_point_position(_nb_current_tape_points-1, masking_tape.contact_floor.global_position)
		masking_tape.reroll_target = _current_tape.get_point_position(_nb_current_tape_points-1) - masking_tape.contact_floor.position * masking_tape.scale
		add_tape_point(masking_tape.contact_floor.global_position)


func _on_menu_button_selected(type: Variant) -> void:
	if type == ScotchMenuButton.ButtonType.RESUME :
		pause_menu.visible = not pause_menu.visible
		if pause_menu.visible :
			menu_music.play()
			main_music.stop()
		else :
			menu_music.stop()
			main_music.play()
		masking_tape.process_mode = Node.PROCESS_MODE_DISABLED if pause_menu.visible else Node.PROCESS_MODE_INHERIT
	elif type == ScotchMenuButton.ButtonType.RESET :
		get_tree().reload_current_scene()


func _on_masking_tape_touch_frame() -> void:
	masking_tape.visible = false
	masking_tape.process_mode = Node.PROCESS_MODE_DISABLED
	roll_frame.visible = true
	roll_frame.play("default")
	_victory_timer.stop()
	_victory_timer.wait_time = 2.0
	_victory_timer.start()
	main_music.stop()
	victory_music.play()


func _on_start_menu_start_game() -> void :
	start_menu.visible = false
	menu_music.stop()
	main_music.play()
	masking_tape.process_mode = Node.PROCESS_MODE_INHERIT
	
func _on_victory_timer_timeout() -> void :
	paint.visible = true
	paint.play("default")

func _on_background_animated_animation_finished() -> void:
	roll_frame.visible = false
	victory_dance.visible = true
	victory_dance.play("default")
