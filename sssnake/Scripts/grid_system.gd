extends Node2D

const GRID_SIZE: int = 32

@onready var game_area: Node2D = $".."
@onready var walls: Node2D = $"../Walls"

@export var wall_scene 			: PackedScene
@export var player				: CharacterBody2D
@export var standard_grid_color : Color = Color(0.872, 2.0, 0.624, 1.0)
@export var walled : bool 

var grid_width			: int
var grid_height			: int
var grid_origin 		: Vector2
var horizontal_grids 	: int
var vertical_grids 		: int
var shiny_grid_color 	: Color = Color(0.639, 4.0, 0.15, 1.0)
var vertical_color 		: Color
var horizontal_color	: Color

func _ready() -> void:
	grid_width = game_area.grid_width
	grid_height= game_area.grid_height
	horizontal_grids = grid_width / GRID_SIZE
	vertical_grids 	= grid_height / GRID_SIZE
	if walled:
		create_walls()

func _draw() -> void:
	
	for i in range(0,grid_width+1,GRID_SIZE): # vertical
		draw_line(Vector2i(i,0),Vector2i(i,grid_height),vertical_color)
	for i in range(0,grid_height+1,GRID_SIZE): # horizontal
		draw_line(Vector2i(0,i),Vector2i(grid_width,i),horizontal_color)

func create_walls() -> void:
	for i in range(0,grid_width+1,GRID_SIZE): # vertical
		var wall_top = wall_scene.instantiate()
		walls.add_child(wall_top)
		wall_top.global_position = Vector2i(i,0)
		var wall_bottom = wall_scene.instantiate()
		walls.add_child(wall_bottom)
		wall_bottom.global_position = Vector2i(i,grid_width)
	for i in range(0,grid_height+1,GRID_SIZE): # vertical
		var wall_left = wall_scene.instantiate()
		walls.add_child(wall_left)
		wall_left.global_position = Vector2i(0,i)
		var wall_right = wall_scene.instantiate()
		walls.add_child(wall_right)
		wall_right.global_position = Vector2i(grid_height,i)
		
