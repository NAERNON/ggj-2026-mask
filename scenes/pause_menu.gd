class_name PauseMenu extends Node2D

@export var resume_button: ScotchMenuButton
@export var reset_button: ScotchMenuButton

signal button_selected(type)

var _current_highlight: ScotchMenuButton.ButtonType

func _ready() -> void:
	_current_highlight = ScotchMenuButton.ButtonType.RESUME
	resume_button.highlight()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		match _current_highlight:
			ScotchMenuButton.ButtonType.RESUME:
				_highlight(ScotchMenuButton.ButtonType.RESET)
			ScotchMenuButton.ButtonType.RESET:
				_highlight(ScotchMenuButton.ButtonType.RESUME)
	elif visible and event.is_action_pressed("ui_accept"):
		button_selected.emit(_current_highlight)
	elif event.is_action_pressed("ui_cancel"):
		button_selected.emit(ScotchMenuButton.ButtonType.RESUME)

func _highlight(type: ScotchMenuButton.ButtonType):
	_current_highlight = type
	match type:
		ScotchMenuButton.ButtonType.RESUME:
			resume_button.highlight()
			reset_button.unhighlight()
		ScotchMenuButton.ButtonType.RESET:
			reset_button.highlight()
			resume_button.unhighlight()
