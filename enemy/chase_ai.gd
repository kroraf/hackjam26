extends Node
class_name ChaseAI

@export var character: CharacterBody2D
@export var agent: NavigationAgent2D
@export var anchor: Node2D
@export var speed: float
@export var move_controller: Node

var player: CharacterBody2D

func _ready() -> void:
	player = character.player
	if character == null or agent == null or player == null:
		push_warning("ChaseAI missing references.")
		set_physics_process(false)
		return
	
	agent.path_desired_distance = 6.0
	agent.target_desired_distance = 12.0

func _physics_process(delta: float) -> void:
	move_controller.move(delta, player.global_position, character, speed)

	character.move_and_slide()

	if anchor != null and abs(character.velocity.x) > 1.0:
		anchor.scale.x = sign(character.velocity.x)
