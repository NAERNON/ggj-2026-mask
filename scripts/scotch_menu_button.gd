class_name ScotchMenuButton extends Node2D

enum ButtonType {
	START,
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
		ButtonType.START:
			_sprite.play("start_default")

func highlight() -> void:
	_sprite.modulate = Color.WHITE
	match button_type:
		ButtonType.RESUME:
			_sprite.play("resume_forward")
		ButtonType.RESET:
			_sprite.play("reset_forward")
		ButtonType.START:
			_sprite.play("start_forward")

func unhighlight(animated: bool = true) -> void:
	_sprite.modulate = Color(0.6, 0.6, 0.6, 1.0)
	
	if not animated: return
	match button_type:
		ButtonType.RESUME:
			_sprite.play("resume_backward")
		ButtonType.RESET:
			_sprite.play("reset_backward")
