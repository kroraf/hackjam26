class_name EnemyStateController extends Node

enum State {PATROL,
			CHASE}

@export var patrol_ai: Node
@export var chase_ai: Node

var _state: State

func _ready() -> void:
	_set_state(State.PATROL)
	EventBus.player_spotted.connect(_on_player_spotted)
	EventBus.player_lost.connect(_on_player_lost)

func _set_state(new_state: State):
	_state = new_state
	EventBus.state_changed.emit(new_state)
	match _state:
		State.PATROL:
			#print("entering patrol state")
			patrol_ai.set_physics_process(false)
			chase_ai.set_physics_process(true)
		State.CHASE:
			#print("entering chase state")
			patrol_ai.set_physics_process(false)
			chase_ai.set_physics_process(true)
			

func _on_player_spotted(character) -> void:
	character.enemy_state_controller._set_state(State.CHASE)
	#print("spotted!")

func _on_player_lost(character) -> void:
	character.enemy_state_controller._set_state(State.PATROL)
