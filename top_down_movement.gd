extends Node
class_name TopDownMovement

@export var character: CharacterBody2D
@export var speed: float = 50

func _physics_process(delta: float) -> void:
	if character == null:
		return

	var input_vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()

	character.velocity = input_vector * speed
	character.move_and_slide()
	
	if input_vector != Vector2.ZERO:
		character.animation_player.play("walk")
		if character.anchor != null and input_vector.x != 0.0:
				character.anchor.scale.x = sign(input_vector.x)
	else:
		character.animation_player.play("idle")
