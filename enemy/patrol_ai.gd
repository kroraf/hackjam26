extends Node
class_name PatrolAI

# -------------------------------------------------
# ENUMS
# -------------------------------------------------

enum State {
	RETURN_TO_START,
	PATROLLING
}

# -------------------------------------------------
# EXPORTS
# -------------------------------------------------

@export var character: CharacterBody2D
@export var move_controller: EnemyMoveController
@export var anchor: Node2D

@export var speed: float = 120.0
@export var arrive_distance: float = 8.0

# -------------------------------------------------
# INTERNAL STATE
# -------------------------------------------------

var start_marker: Marker2D
var finish_marker: Marker2D

var _state: State = State.RETURN_TO_START
var _going_to_finish: bool = true

var _agent: NavigationAgent2D
var _return_target_set: bool = false

# -------------------------------------------------
# LIFECYCLE
# -------------------------------------------------

func _ready() -> void:
	if character == null:
		push_warning("PatrolAI: character not assigned.")
		set_physics_process(false)
		return

	start_marker = character.start_marker
	finish_marker = character.finish_marker
	
	if start_marker == null or finish_marker == null:
		push_warning("PatrolAI: start_marker or finish_marker not set on enemy.")
		set_physics_process(false)
		return

	_agent = character.get_node_or_null("NavigationAgent2D")
	if _agent == null:
		push_warning("PatrolAI: NavigationAgent2D missing.")
		set_physics_process(false)
		return

	_agent.path_desired_distance = arrive_distance
	_agent.target_desired_distance = arrive_distance

	call_deferred("_initialize_state")

func _initialize_state() -> void:
	_state = State.RETURN_TO_START
	_return_target_set = false

# -------------------------------------------------
# UPDATE
# -------------------------------------------------

func _physics_process(delta: float) -> void:
	match _state:
		State.RETURN_TO_START:
			_move_to_start()

		State.PATROLLING:
			_patrol(delta)

# -------------------------------------------------
# PUBLIC API (CALLED BY BRAIN)
# -------------------------------------------------

func activate_patrol() -> void:
	_state = State.RETURN_TO_START
	_return_target_set = false

func stop_patrol() -> void:
	character.velocity = Vector2.ZERO

# -------------------------------------------------
# RETURN TO START (NAVIGATION)
# -------------------------------------------------

func _move_to_start() -> void:
	if not _return_target_set:
		_agent.target_position = start_marker.global_position
		_return_target_set = true

	if _agent.is_navigation_finished():
		_agent.target_position = character.global_position
		_state = State.PATROLLING
		character.velocity = Vector2.ZERO
		return

	_move_along_nav()

# -------------------------------------------------
# PATROL LOGIC (DIRECT MOVE)
# -------------------------------------------------

func _patrol(delta) -> void:
	var target: Marker2D = (
		finish_marker if _going_to_finish else start_marker
	)

	var to_target: Vector2 = target.global_position - character.global_position
	if to_target.length() <= arrive_distance:
		_going_to_finish = not _going_to_finish
		return

	character.velocity = to_target.normalized() * speed
	
	character.move_and_slide()
	_update_facing_from_velocity()

# -------------------------------------------------
# NAVIGATION MOVEMENT
# -------------------------------------------------

func _move_along_nav() -> void:
	var next_pos: Vector2 = _agent.get_next_path_position()
	var dir: Vector2 = next_pos - character.global_position

	if dir.length() < 0.01:
		character.velocity = Vector2.ZERO
		return

	character.velocity = dir.normalized() * speed
	character.move_and_slide()
	_update_facing_from_velocity()

# -------------------------------------------------
# HELPERS
# -------------------------------------------------

func _update_facing_from_velocity() -> void:
	if anchor != null and abs(character.velocity.x) > 0.01:
		anchor.scale.x = sign(character.velocity.x)
