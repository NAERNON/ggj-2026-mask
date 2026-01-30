class_name MaskingTape extends CharacterBody2D

@export_range(0.0, 100.0, 1.0) var gravity : float

func _physics_process(delta : float) -> void :
	velocity.y += gravity * delta
	move_and_slide()
