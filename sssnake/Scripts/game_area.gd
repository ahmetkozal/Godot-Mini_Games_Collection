extends Node2D

@export var grid_width: int = 160
@export var grid_height: int = 160

func _ready() -> void:
	print("Viewport: ", get_viewport_rect().size)
	print("Grid size: ", Vector2(grid_width, grid_height))
	print("GameArea position before: ", position)

	position = (get_viewport_rect().size - Vector2(grid_width, grid_height)) / 2

	print("GameArea position after: ", position)
