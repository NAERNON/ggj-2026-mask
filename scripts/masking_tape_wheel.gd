class_name MaskingTapeWheel extends Node2D

var _wheel_sprite: Sprite2D = Sprite2D.new()

var max_weight: float = 4.0:
	set(new_value):
		max_weight = new_value
		queue_redraw()

var fill_ratio: float = 1.0:
	set(new_value):
		if fill_ratio == new_value: return
		
		fill_ratio = new_value
		queue_redraw()

func _ready() -> void:
	_wheel_sprite.texture = load("res://aseprite/character_face/wheel.png")
	add_child(_wheel_sprite)

func _draw() -> void:
	var default_radius: float = 15.5
	var radius: float = default_radius + max_weight * fill_ratio
	draw_circle(Vector2.ZERO, radius, Color("ffeca2"), true, -1.0, false)
