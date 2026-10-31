extends CharacterBody2D

const MIN_K : float = 0.2

@export var grid_system 	: Node2D
@export var body_part_scene : PackedScene  
@onready var head: Sprite2D = $HeadArea/Head
@onready var score_label: Label = $"../../GameUI/LeftPanel/PanelContainer/ScoreAndMove/ScoreVBox/ScoreLabel"
@onready var move_label: Label = $"../../GameUI/LeftPanel/PanelContainer/ScoreAndMove/MoveVBox/MoveNumber"
@onready var body_parts 	: Node2D = $Body
@onready var CELL_SIZE 		: int = grid_system.GRID_SIZE
@onready var game_over_label: Label = $"../../GameUI/GameOverLabel"

var max_point		: int
var empty_grids 	: Array[Vector2i] = []
var grid_array 		: Array[Vector2i] = []
var rotation_array	: Array[float] = []
var parts			: Array[Node2D] = []
var point 			: int = 0
var move			: int = 0
var k 				: float = 1.0
var base_move_timer : float = 0.5 
var move_timer 		: float = 0.0
var dir 			: Vector2i
var prev_dir 		: Vector2i
var can_input 		: bool
var grid_pos		: Vector2i
var current_rot		: float
var boost_enabled 	: bool = false
var body_enabled 	: bool
var wall_enabled 	: bool
var max_x 			: int
var max_y 			: int
var dead			: bool = false
func _ready() -> void:
	move_label.text = str(move)
	score_label.text = str(point)
	position 	= grid_system.grid_origin + Vector2(grid_system.horizontal_grids,grid_system.vertical_grids) /2 * CELL_SIZE
	dir 		= Vector2i.RIGHT
	prev_dir 	= dir * -1
	can_input 	= true
	control_shiny_grids(dir)
	grid_pos = position / CELL_SIZE
	body_enabled = grid_system.body_enabled
	wall_enabled = grid_system.walled
	max_x = grid_system.horizontal_grids
	max_y = grid_system.vertical_grids
	if wall_enabled:
		max_point = 64
	else:
		max_point = 81

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://UI/snake_main_menu.tscn")
		
	if !dead:
		var move_dir : Vector2i= get_dir()
		if move_timer <= 0.0:
			do_when_moving(move_dir)
		else:
			move_timer -= delta
		if Input.is_action_just_pressed("boost"):
			boost_enabled = true
		if Input.is_action_just_released("boost"):
			boost_enabled = false
	else:
		game_over_label.show()
		if Input.is_action_just_pressed("boost"):
			get_tree().reload_current_scene()

func do_when_moving(move_dir:Vector2i) -> void:
	log_grid()
	grid_pos += move_dir
	position = grid_pos * CELL_SIZE
	move+=1
	move_label.text = str(move)
	current_rot = Vector2(move_dir).angle()
	if !wall_enabled:
		teleport_in_grid()
	head.global_rotation = current_rot
	prev_dir = move_dir
	can_input = true
	if boost_enabled:
		move_timer = base_move_timer * k /2.5
	else:
		move_timer = base_move_timer * k
	log_rotation()
	update_part_pos()
	update_part_rotation()

func get_dir() -> Vector2i:
	if (Input.is_action_just_pressed("down") or Input.is_action_just_pressed("ui_down")) && prev_dir != Vector2i.UP && can_input:
		dir = Vector2i.DOWN
		can_input = false
		control_shiny_grids(dir)

	elif (Input.is_action_just_pressed("up")  or Input.is_action_just_pressed("ui_up")) && prev_dir != Vector2i.DOWN && can_input:
		dir = Vector2i.UP
		can_input = false
		control_shiny_grids(dir)

	elif (Input.is_action_just_pressed("left")  or Input.is_action_just_pressed("ui_left")) && prev_dir != Vector2i.RIGHT && can_input:
		dir = Vector2i.LEFT
		can_input = false
		control_shiny_grids(dir)

	elif (Input.is_action_just_pressed("right")  or Input.is_action_just_pressed("ui_right")) && prev_dir != Vector2i.LEFT && can_input:
		dir = Vector2i.RIGHT
		can_input = false
		control_shiny_grids(dir)

	return dir

func teleport_in_grid() -> void:
	if position.x < 0:
		position.x = max_x * CELL_SIZE
	elif position.x > max_x * CELL_SIZE:
		position.x = 0
	if position.y < 0:
		position.y = max_y * CELL_SIZE 
	elif position.y > max_y * CELL_SIZE:
		position.y = 0
	grid_pos = position / CELL_SIZE

func log_grid() -> void:
	grid_array.append(grid_pos)
	while grid_array.size() > point + 2:
		grid_array.remove_at(0)

func log_rotation() -> void:
	rotation_array.append(current_rot)
	while rotation_array.size() > point + 2:
		rotation_array.remove_at(0)

func grow_snake() -> void:
	var body_part = body_part_scene.instantiate()
	body_parts.add_child(body_part)
	body_part.global_position = grid_system.to_global(Vector2(grid_array[1] * CELL_SIZE))
	parts.append(body_part)
	if point >= max_point:
		dead = true

func update_part_pos() -> void:
	for i in range(0,parts.size()):
		parts[i].global_position = grid_system.to_global(Vector2(grid_array[grid_array.size() - i - 1] * CELL_SIZE))
		

func update_part_rotation() -> void:
	for i in range(0,parts.size()):
		parts[i].global_rotation = rotation_array[rotation_array.size() - i - 1]

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
	if k >= MIN_K:
		k -= 0.05
	if k <= MIN_K:
		k = MIN_K
	score_label.text = str(point)
	grow_snake.call_deferred()

func _on_head_area_area_entered(area: Area2D) -> void:
	if wall_enabled and area.get_collision_layer_value(4):
		dead = true
	if body_enabled and area.get_collision_layer_value(2):
		dead = true
