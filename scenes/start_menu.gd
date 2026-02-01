class_name StartMenu extends Node2D

@export var play_button: ScotchMenuButton

signal start_game()

func _ready() -> void:
	play_button.highlight()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept"):
		start_game.emit()
