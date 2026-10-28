extends Node2D

const GRID_SIZE: int = 16

@export var player				: CharacterBody2D
@export var standard_grid_color : Color = Color(0.872, 2.0, 0.624, 1.0)
@export var grid_width			: int = 640
@export var grid_height			: int = 480

var horizontal_grids 	: int
var vertical_grids 		: int
var shiny_grid_color 	: Color = Color(0.639, 4.0, 0.15, 1.0)
var vertical_color 		: Color
var horizontal_color	: Color

func _ready() -> void:
	horizontal_grids = grid_width / GRID_SIZE
	vertical_grids 	= grid_height / GRID_SIZE

func _draw() -> void:
	
	for i in range(0,grid_width+1,GRID_SIZE): # vertical
		draw_line(Vector2i(i,0),Vector2i(i,grid_height),vertical_color)
	for i in range(0,grid_height+1,GRID_SIZE): # horizontal
		draw_line(Vector2i(0,i),Vector2i(grid_width,i),horizontal_color)
