extends PointLight2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Game finished")
	Music.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.start("1lvl_5").process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.timeline_ended.connect(_dialog_finished)
	get_tree().paused = true
	
func _dialog_finished():
	get_tree().paused = false
