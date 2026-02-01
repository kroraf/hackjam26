extends Node2D

@onready var title_screen: Sprite2D = $CanvasLayer/TitleScreen
@onready var title_timer: Timer = $TitleTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Music.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.start("1lvl_1").process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.timeline_ended.connect(_dialog_finished)
	get_tree().paused = true
	
func _dialog_finished():
	get_tree().paused = false
