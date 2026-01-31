extends Node2D

@export var masking_tape : MaskingTape
@export_range(0.0, 1.0, 0.01) var epsilon_tape : float
@export_range(0.0, 5.0, 0.01) var epsilon_corner : float

@export var platforms : Node

var _masking_tapes : Array[Line2D]

var _current_tape : Line2D
var _nb_current_tape_points : int
var _current_param_dor : Vector3

var _platform_corners : Array[Vector2]


func _ready() -> void :
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

func _physics_process(_delta : float) -> void :
	if _current_tape :
		_current_tape.set_point_position(_nb_current_tape_points-1, masking_tape.position)
		
		if _nb_current_tape_points > 2 :
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
					_current_tape.add_point(corner, _nb_current_tape_points-1)
					_nb_current_tape_points += 1

func get_param_d(p1 : Vector2, p2 : Vector2) -> Vector3 :
		var param_d : Vector3

		param_d.x = -p1.y + p2.y
		param_d.y = p1.x - p2.x
		param_d.z = -param_d.x * p1.x - param_d.y * p1.y

		return param_d

func _on_masking_tape_end_grip() -> void:
	if _current_tape :
		_masking_tapes.append(_current_tape)
	_current_tape = null

func _on_masking_tape_start_grip() -> void:
	_current_tape = Line2D.new()
	self.add_child(_current_tape)
	_current_tape.width = 2.5
	_nb_current_tape_points = 0
	masking_tape.reroll_target = Vector2.INF

	_current_tape.add_point(masking_tape.position)
	_nb_current_tape_points += 1

	if masking_tape.is_on_wall() or masking_tape.is_on_floor() :
		masking_tape.reroll_target = _current_tape.get_point_position(_nb_current_tape_points-1)
		_current_tape.add_point(masking_tape.position)
		_nb_current_tape_points += 1

func _on_masking_tape_touch_or_leave_floor() -> void:
	if _current_tape :
		masking_tape.reroll_target = _current_tape.get_point_position(_nb_current_tape_points-1)
		_current_tape.add_point(masking_tape.position)
		_nb_current_tape_points += 1

func _on_masking_tape_reroll() -> void:
	if masking_tape.position.distance_to(masking_tape.reroll_target) < epsilon_tape :
		_current_tape.remove_point(_nb_current_tape_points-2)
		_nb_current_tape_points -= 1

		if _nb_current_tape_points < 2 :
			masking_tape.reroll_target = Vector2.INF
			masking_tape.is_gripping = false
		else :
			masking_tape.reroll_target = _current_tape.get_point_position(_nb_current_tape_points-2)
