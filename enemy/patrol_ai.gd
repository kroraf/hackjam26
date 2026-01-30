extends Node
class_name PatrolAI

enum PatrolMode {
	LOOP,
	PING_PONG
}

@export var character: CharacterBody2D
@export var anchor: Node2D

@export var speed: float = 30
@export var patrol_mode: PatrolMode = PatrolMode.PING_PONG
@export var snap_to_path_on_start: bool = true

var _curve: Curve2D
var _path: Path2D
var _path_length := 0.0
var _distance := 0.0
var _direction := 1.0

func _ready() -> void:
	if character == null:
		push_warning("PatrolAI: character not assigned.")
		set_physics_process(false)
		return

	_path = character.patrol_path
	if _path == null:
		push_warning("PatrolAI: character.patrol_path is null.")
		set_physics_process(false)
		return

	_curve = _path.curve
	if _curve == null:
		push_warning("PatrolAI: Path2D has no Curve2D.")
		set_physics_process(false)
		return

	_curve.bake_interval = 5.0
	_path_length = _curve.get_baked_length()

	if snap_to_path_on_start:
		_set_position_from_distance()

func _physics_process(delta: float) -> void:
	_advance_distance(delta)
	_set_position_from_distance()
	_update_facing()

func _advance_distance(delta: float) -> void:
	_distance += speed * _direction * delta

	match patrol_mode:
		PatrolMode.LOOP:
			_distance = fposmod(_distance, _path_length)

		PatrolMode.PING_PONG:
			if _distance > _path_length:
				_distance = _path_length
				_direction = -1.0
			elif _distance < 0.0:
				_distance = 0.0
				_direction = 1.0

func _set_position_from_distance() -> void:
	var local_pos := _curve.sample_baked(_distance)
	character.global_position = _path.to_global(local_pos)

func _update_facing() -> void:
	if anchor == null:
		return

	var look_ahead: float = clamp(
		_distance + _direction * 1.0,
		0.0,
		_path_length
	)

	var current := _path.to_global(_curve.sample_baked(_distance))
	var ahead := _path.to_global(_curve.sample_baked(look_ahead))

	var dx := ahead.x - current.x
	if abs(dx) > 0.01:
		anchor.scale.x = sign(dx)
