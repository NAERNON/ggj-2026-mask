@abstract
class_name AnimationGraph extends Node2D

@onready var _sprite: AnimatedSprite2D = AnimatedSprite2D.new()
@onready var _timer: Timer = Timer.new()

var _state: int = -1
var _current_transi: AnimationGraphTransition

@abstract func sprite_frames() -> SpriteFrames
@abstract func animation_to_play_for_state(state: int) -> String
@abstract func transition_after_state(state: int) -> AnimationGraphTransition

func _ready() -> void:
	_sprite.sprite_frames = sprite_frames()
	add_child(_sprite)
	
	_timer.one_shot = true;
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	
	_sprite.animation_finished.connect(_on_animation_finished)

func _on_timer_timeout() -> void:
	set_state(_current_transi.destination_state)

func _on_animation_finished() -> void:
	if _current_transi == null: return
	
	if _current_transi.start_type == AnimationGraphTransition.StartType.ON_ANIMATION_END:
		_start_timer_for_current_transi()

func _start_timer_for_current_transi() -> void:
	if _current_transi.delay == 0.0:
		set_state(_current_transi.destination_state)
	else:
		_timer.wait_time = _current_transi.delay
		_timer.start()

func set_state(state: int) -> void:
	_state = state
	_sprite.play(animation_to_play_for_state(state))
	_timer.stop()
	
	var transi: AnimationGraphTransition = transition_after_state(state)
	_current_transi = transi
	if transi != null and transi.start_type == AnimationGraphTransition.StartType.ON_ANIMATION_START:
		_start_timer_for_current_transi()
