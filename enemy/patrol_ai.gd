extends Node
class_name PatrolAI

enum State {
	RETURN_TO_PATH,
	ON_PATH
}

enum PatrolMode {
	LOOP,
	PING_PONG
}

@export var character: CharacterBody2D
@export var anchor: Node2D

@export var speed: float = 120.0
@export var arrive_distance: float = 8.0
@export var patrol_mode: PatrolMode = PatrolMode.PING_PONG
@export var move_controller: EnemyMoveController

var patrol_path: Path2D
var _curve: Curve2D
var _path_length: float = 0.0

var _distance: float = 0.0
var _direction: float = 1.0
var _state: State = State.RETURN_TO_PATH

func _ready() -> void:
	if character == null:
		push_warning("PatrolAI: character not assigned.")
		set_physics_process(false)
		return

	patrol_path = character.patrol_path
	if patrol_path == null:
		push_warning("PatrolAI: character.patrol_path is null.")
		set_physics_process(false)
		return

	_curve = patrol_path.curve
	if _curve == null:
		push_warning("PatrolAI: patrol_path has no Curve2D.")
		set_physics_process(false)
		return

	_curve.bake_interval = 5.0
	_path_length = _curve.get_baked_length()

	if _is_on_path():
		print("---------------------------")
		_distance = _get_closest_offset()
		_state = State.ON_PATH
	else:
		_state = State.RETURN_TO_PATH

func _physics_process(delta: float) -> void:
	match _state:
		State.RETURN_TO_PATH:
			_move_to_path_start(delta)
			print("returning...")

		State.ON_PATH:
			# If we somehow got off the path, go back
			if not _is_on_path():
				_state = State.RETURN_TO_PATH
			else:
				_patrol(delta)


# ----------------------------
# RETURN TO PATH
# ----------------------------

func _move_to_path_start(delta: float) -> void:
	var start_global: Vector2 = patrol_path.to_global(
		_curve.sample_baked(0.0)
	)
	move_controller.move(delta, start_global, speed)
	#var to_start: Vector2 = start_global - character.global_position
	#if to_start.length() <= arrive_distance:
		#_distance = 0.0
		#_state = State.ON_PATH
		#character.velocity = Vector2.ZERO
		#return
#
	#var dir: Vector2 = to_start.normalized()
	#character.velocity = dir * speed
	character.move_and_slide()
	_update_facing_from_velocity()
	

# ----------------------------
# ON PATH (RAIL PATROL)
# ----------------------------

func _patrol(delta: float) -> void:
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

	var local_pos: Vector2 = _curve.sample_baked(_distance)
	character.global_position = patrol_path.to_global(local_pos)
	_update_facing_from_path()

# ----------------------------
# HELPERS
# ----------------------------

func _is_on_path() -> bool:
	var closest_dist: float = (
		patrol_path.to_global(
			_curve.get_closest_point(
				patrol_path.to_local(character.global_position)
			)
		) - character.global_position
	).length()

	return closest_dist <= arrive_distance

func _get_closest_offset() -> float:
	return _curve.get_closest_offset(
		patrol_path.to_local(character.global_position)
	)

func _update_facing_from_velocity() -> void:
	if anchor != null and abs(character.velocity.x) > 0.01:
		anchor.scale.x = sign(character.velocity.x)

func _update_facing_from_path() -> void:
	if anchor == null:
		return

	var look_ahead: float = clamp(
		_distance + _direction * 1.0,
		0.0,
		_path_length
	)

	var current: Vector2 = patrol_path.to_global(
		_curve.sample_baked(_distance)
	)
	var ahead: Vector2 = patrol_path.to_global(
		_curve.sample_baked(look_ahead)
	)

	var dx: float = ahead.x - current.x
	if abs(dx) > 0.01:
		anchor.scale.x = sign(dx)
