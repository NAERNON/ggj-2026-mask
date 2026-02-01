class_name ScotchMenuButton extends Node2D

enum ButtonType {
	RESUME,
	RESET,
}

@export var button_type: ButtonType = ButtonType.RESUME

@onready var _sprite: AnimatedSprite2D = AnimatedSprite2D.new()

func _ready() -> void:
	_sprite.sprite_frames = load("uid://dhoxvco111rye")
	add_child(_sprite)
	
	match button_type:
		ButtonType.RESUME:
			_sprite.play("resume_default")
		ButtonType.RESET:
			_sprite.play("reset_default")

func highlight() -> void:
	_sprite.modulate = Color(0.7, 0.7, 0.7, 1.0)
	match button_type:
		ButtonType.RESUME:
			_sprite.play("resume_forward")
		ButtonType.RESET:
			_sprite.play("reset_forward")

func unhighlight() -> void:
	_sprite.modulate = Color.WHITE
	match button_type:
		ButtonType.RESUME:
			_sprite.play("resume_backward")
		ButtonType.RESET:
			_sprite.play("reset_backward")
