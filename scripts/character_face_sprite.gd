class_name CharacterFaceSprite extends AnimationGraph

var _sleep_timer: Timer = Timer.new()
@export var to_sleep : bool = true

enum State {
	IDLE,
	IDLE_ANIM,
	SLEEP_START,
	SLEEP_001,
	SLEEP_002,
	RUN_SLOW_LEFT,
	RUN_SLOW_RIGHT,
	RUN_FAST_LEFT,
	RUN_FAST_RIGHT,
}

func _ready() -> void:
	add_child(_sleep_timer)
	_sleep_timer.one_shot = true
	_sleep_timer.timeout.connect(_on_sleep_timer_timeout)
	
	super()
	set_state(State.IDLE)

func _on_sleep_timer_timeout() -> void:
	set_state(State.SLEEP_START)

func sprite_frames() -> SpriteFrames:
	return load("uid://bwh5qaed5uy1u")

func animation_to_play_for_state(state: int) -> String:
	match state:
		State.IDLE: return "default"
		State.IDLE_ANIM: return "idle%03d" % randi_range(1,4)
		State.SLEEP_START: return "sleep_start"
		State.SLEEP_001: return "sleep001"
		State.SLEEP_002: return "sleep002"
		State.RUN_SLOW_LEFT: return "run_slow_left"
		State.RUN_SLOW_RIGHT: return "run_slow_right"
		State.RUN_FAST_LEFT: return "run_fast_left"
		State.RUN_FAST_RIGHT: return "run_fast_right"
	return String()

func transition_after_state(state: int) -> AnimationGraphTransition:
	match state:
		State.IDLE:
			return AnimationGraphTransition.random(
				State.IDLE_ANIM, 1.0, 3.0
			)
		State.IDLE_ANIM:
			return AnimationGraphTransition.random(
				State.IDLE_ANIM, 1.0, 5.0
			)
		State.SLEEP_START:
			return AnimationGraphTransition.simple(State.SLEEP_001)
		State.SLEEP_001:
			return AnimationGraphTransition.simple(
				State.SLEEP_002,
				3.0,
				AnimationGraphTransition.StartType.ON_ANIMATION_START
			)
	return null

func set_state(state: int) -> void:
	super(state)
	
	if state == State.IDLE and to_sleep:
		_sleep_timer.stop()
		_sleep_timer.wait_time = 5.0
		_sleep_timer.start()

func get_state() -> int :
	return _state
