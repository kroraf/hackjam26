class_name EnemyStats extends Resource


@export var awareness := 0.0:
	set(value):
		awareness = clamp(value, 0.0, max_awareness)
		awareness_changed.emit()
		if awareness <= 0: awareness_zero.emit()
		if awareness >= max_awareness: awareness_full.emit()

@export var max_awareness := 3.0

signal awareness_changed
signal awareness_zero
signal awareness_full
