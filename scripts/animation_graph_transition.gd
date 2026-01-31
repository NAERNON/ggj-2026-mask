class_name AnimationGraphTransition extends RefCounted

var destination_state: int
var delay: float
var start_type: StartType

enum StartType {
	ON_ANIMATION_START,
	ON_ANIMATION_END
}

static func none() -> AnimationGraphTransition:
	var transi: AnimationGraphTransition = AnimationGraphTransition.new()
	transi.destination_state = -1
	transi.delay = 0.0
	return transi

static func simple(
	dest_state: int,
	del: float = 0.0,
	st_type: StartType = StartType.ON_ANIMATION_END
) -> AnimationGraphTransition:
	var transi: AnimationGraphTransition = AnimationGraphTransition.new()
	transi.destination_state = dest_state
	transi.delay = del
	transi.start_type = st_type
	return transi

static func random(
	dest_state: int,
	delay_min: float,
	delay_max: float,
	st_type: StartType = StartType.ON_ANIMATION_END
) -> AnimationGraphTransition:
	var transi: AnimationGraphTransition = AnimationGraphTransition.new()
	transi.destination_state = dest_state
	transi.delay = randf_range(delay_min, delay_max)
	transi.start_type = st_type
	return transi
