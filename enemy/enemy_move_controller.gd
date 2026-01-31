class_name EnemyMoveController extends Node

@onready var agent: NavigationAgent2D = $"../NavigationAgent2D"
@export var character: CharacterBody2D

func move(delta, target, speed):
	agent.target_position = target

	if agent.is_navigation_finished():
		character.velocity = Vector2.ZERO
		return

	var next_pos: Vector2 = agent.get_next_path_position()
	var move_dir: Vector2 = (next_pos - character.global_position)

	if move_dir.length_squared() > 0.001:
		move_dir = move_dir.normalized()
		character.velocity = move_dir * speed
	else:
		character.velocity = Vector2.ZERO
