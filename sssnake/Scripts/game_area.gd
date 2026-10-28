extends Node2D

@export var grid_width: int = 160
@export var grid_height: int = 160

func _ready() -> void:
	position = (get_viewport_rect().size - Vector2(grid_width, grid_height)) / 2
