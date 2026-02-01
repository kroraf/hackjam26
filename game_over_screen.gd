extends Control

@onready var button: Button = $TextureRect/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
