extends CharacterBody2D


@onready var anchor: Node2D = $Anchor
@onready var point_light_2d: PointLight2D = $Anchor/PointLight2D
@export var patrol_path: Path2D
