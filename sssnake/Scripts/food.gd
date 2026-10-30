extends Node2D

@export var grid_system : Node2D
@export var snake : CharacterBody2D

@onready var CELL_SIZE 			: int = grid_system.GRID_SIZE
@onready var HORIZONTAL_GRIDS 	: int = grid_system.horizontal_grids
@onready var VERTICAL_GRIDS 	: int = grid_system.vertical_grids

func _ready() -> void:
	position = get_random_grid() * CELL_SIZE

func _on_area_2d_body_entered(body: Node2D) -> void:
	position = get_random_grid() * CELL_SIZE

func get_random_int(range_int : int) -> int:
	return randi_range(0,range_int)

func get_random_grid() -> Vector2i:
	var rand_x : int = get_random_int(HORIZONTAL_GRIDS)
	var rand_y : int = get_random_int(VERTICAL_GRIDS)
	if Vector2i(rand_x,rand_y) in snake.grid_array:
		return get_random_grid()
	return Vector2i(rand_x,rand_y)
