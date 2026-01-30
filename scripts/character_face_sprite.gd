class_name CharacterFaceSprite extends Node2D

@onready var _sprite: AnimatedSprite2D = AnimatedSprite2D.new()
@onready var _timer: Timer = Timer.new()
@onready var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _state: State = State.IDLE;

enum State {
	IDLE
}

func _ready() -> void:
	var sprite_frames: SpriteFrames = load("uid://bwh5qaed5uy1u")
	_sprite.sprite_frames = sprite_frames
	_sprite.play("default")
	add_child(_sprite)
	
	_timer.one_shot = true;
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	
	set_state(State.IDLE)

func _on_timer_timeout() -> void:
	match _state:
		State.IDLE:
			_sprite.play("idle001")
			_start_idle_animation_timer()

func _start_idle_animation_timer() -> void:
	_timer.stop()
	_timer.wait_time = _rng.randf_range(1.0, 3.0)
	_timer.start()

func set_state(state: State) -> void:
	_state = state
	_sprite.play("default")
	_start_idle_animation_timer()
