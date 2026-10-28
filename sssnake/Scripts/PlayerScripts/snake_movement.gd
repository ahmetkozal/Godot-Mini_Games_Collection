extends CharacterBody2D

@export var grid_system : Node2D

@onready var CELL_SIZE : int = grid_system.GRID_SIZE

var grid_array 		: Array[Vector2i] = []
var point 			: int = 0
var k 				: float = 1.0
var base_move_timer : float = 0.50
var move_timer 		: float = 0.0
var dir 			: Vector2i
var prev_dir 		: Vector2i
var can_input 		: bool
var grid_pos		: Vector2i

func _ready() -> void:
	dir 		= Vector2i.RIGHT
	prev_dir 	= dir * -1
	can_input 	= true
	control_shiny_grids(dir)
	grid_pos = position / CELL_SIZE

func _physics_process(delta: float) -> void:
	var move_dir : Vector2i= get_dir()
	if move_timer <= 0.0:
		log_grid()
		#print(grid_array)
		grid_pos += move_dir
		position = grid_pos * CELL_SIZE
		prev_dir = move_dir
		can_input = true
		move_timer = base_move_timer
	else:
		move_timer -= delta


func get_dir() -> Vector2:
	if Input.is_action_just_pressed("down") && prev_dir != Vector2i.UP && can_input:
		dir = Vector2.DOWN
		can_input = false
		control_shiny_grids(dir)
	elif Input.is_action_just_pressed("up") && prev_dir != Vector2i.DOWN && can_input:
		dir = Vector2.UP
		can_input = false
		control_shiny_grids(dir)
	elif Input.is_action_just_pressed("left") && prev_dir != Vector2i.RIGHT && can_input:
		dir = Vector2.LEFT
		can_input = false
		control_shiny_grids(dir)
	elif Input.is_action_just_pressed("right") && prev_dir != Vector2i.LEFT && can_input:
		dir = Vector2.RIGHT
		can_input = false
		control_shiny_grids(dir)
	return dir

func log_grid() -> void:
	grid_array.append(grid_pos)
	while grid_array.size() > point + 1:
		grid_array.remove_at(0)

func control_shiny_grids(move_dir: Vector2i) -> void:
	if move_dir == Vector2i.UP || move_dir == Vector2i.DOWN:
		grid_system.vertical_color = grid_system.shiny_grid_color
		grid_system.horizontal_color = grid_system.standard_grid_color
	else:
		grid_system.vertical_color = grid_system.standard_grid_color
		grid_system.horizontal_color = grid_system.shiny_grid_color
	grid_system.queue_redraw()


func _on_area_2d_body_entered(body: Node2D) -> void:
	point += 1
