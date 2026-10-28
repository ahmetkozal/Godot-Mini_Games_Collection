extends Node2D

const GRID_SIZE: int = 16

@export var grid_color 			: Color = Color.RED
@export var grid_width		: int = 640
@export var grid_height		: int = 480

func _draw() -> void:
	for i in range(0,grid_width+1,GRID_SIZE):
		draw_line(Vector2(i,0),Vector2(i,grid_height),grid_color)
	for i in range(0,grid_height+1,GRID_SIZE):
		draw_line(Vector2(0,i),Vector2(grid_width,i),grid_color)
