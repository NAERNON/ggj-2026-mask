class_name CharacterFaceSprite extends AnimationGraph

enum State {
	IDLE,
	IDLE_ANIM,
}

func _ready() -> void:
	super()
	set_state(State.IDLE)

func sprite_frames() -> SpriteFrames:
	return load("uid://bwh5qaed5uy1u")

func animation_to_play_for_state(state: int) -> String:
	match state:
		State.IDLE: return "default"
		State.IDLE_ANIM: return "idle%03d" % randi_range(1,4)
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
	return null
