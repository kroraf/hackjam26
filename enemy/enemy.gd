extends CharacterBody2D

@onready var anchor: Node2D = $Anchor
@export var patrol_path: Path2D
@onready var radial_light: PointLight2D = $Anchor/RadialLight
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@export var player: CharacterBody2D
#@export var stats: EnemyStats
@onready var awareness_bar: AwarenessBar = $AwarenessBar
@onready var awareness_loose_timer: Timer = $AwarenessLooseTimer
@onready var awareness_gain_timer: Timer = $AwarenessGainTimer
@export var start_marker: Marker2D
@export var finish_marker: Marker2D
@export var awareness := 0.0:
	set(value):
		awareness = clamp(value, 0.0, max_awareness)
		EventBus.awareness_changed.emit()
		if awareness <= 0: _on_awareness_zero()
		if awareness >= max_awareness: _on_awareness_full()

@export var max_awareness := 3.0
@onready var enemy_state_controller: EnemyStateController = $EnemyStateController


func _ready() -> void:
	#stats = stats.duplicate()
	#awareness_bar.stats = stats
	awareness_gain_timer.timeout.connect(_on_awareness_gain_timer_timeout)
	awareness_loose_timer.timeout.connect(_on_awareness_loose_timer_timeout)
	#stats.awareness_full.connect(_on_awareness_full)
	#stats.awareness_zero.connect(_on_awareness_zero)
	_on_radial_area_body_exited(player)

func _on_radial_area_body_entered(body: Node2D) -> void:
	awareness_gain_timer.start()
	awareness_loose_timer.stop()
	
func _on_awareness_gain_timer_timeout():
	awareness += 1
	
func _on_awareness_loose_timer_timeout():
	awareness -= 0.5

func _on_radial_area_body_exited(body: Node2D) -> void:
	awareness_gain_timer.stop()
	awareness_loose_timer.start()
	
	
func _on_awareness_full():
	EventBus.player_spotted.emit(self)
	
func _on_awareness_zero():
	EventBus.player_lost.emit(self)
