class_name AwarenessBar extends ProgressBar


var stats: EnemyStats:
	set(new_stats):
		stats = new_stats
		if stats is EnemyStats:
			update_awareness()
			EventBus.awareness_changed.connect(_on_awareness_changed)

func _ready():
	modulate = Color.TRANSPARENT

func update_awareness():
	var awareness_percent = stats.awareness / stats.max_awareness * 100
	#print(stats.awareness / stats.max_awareness)
	value = clamp(awareness_percent, min_value, max_value)
	
func _on_awareness_changed() -> void:
	show_temporarily()
	update_awareness()
	
func show_temporarily():
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 2.0).from(Color.WHITE)

func _on_timer_timout():
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.0)
