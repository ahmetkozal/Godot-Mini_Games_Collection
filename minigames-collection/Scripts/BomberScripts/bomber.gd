class_name PlayerBomber
extends CharacterBody2D

# --- vars about game area ---
const 			BOX_EXPLOSION 	= preload("res://Objects/bomber/box_explosion.tscn") 	# Box explosin animation
const 			BOX_SOURCE_ID 	: int = 	0 											# Source id of box in tile set
const 			FLOOR_SOURCE_ID : int = 	1 											# Source id of floor in tile set
const 			WALL_SOURCE_ID 	: int = 	2 											# Source id of wall in tile set
const 			OFFSET 			: int = 	32 											# Grid size actually
@onready var 	game_area		: GameArea = $"../.." 									# game_area scene to get get data about game

# --- vars about player ---
@onready var 	anim 			: AnimatedSprite2D = $AnimatedSprite2D 	# bomber animations
@export var 	player_id 		: int 									# player id is used for taking correct input
@export var 	is_player 		: bool 									# is bomber human controlled or ai
var 			speed 			: float = 70.0 							# bomber speed
var 			dead 			: bool				 					# dead
var 			bombs_planted 	: Array

# --- vars about bombs ---
@onready var 	bombs				: Node2D = $"../../bombs" 	# game scene object to collect bombs
@export var 	bomb 				: PackedScene				# bomb scene
var 			is_cell_bombed 		: bool						# if target cell is bombed
var 			max_bombs 			: int = 1					# how many bomb/s can player plant
var 			bomb_count 			: int = 0					# how many bomb/s player planted
var 			explosion_range 	: int = 1					# explosion radius

# --- vars about navigation and movement ---
var 			current_cell 	: Vector2i 	# bomber's current cell
var 			target_dir 		: Vector2i 	# taking input and setting direction
var 			target_cell 	: Vector2i 	# bomber's current cell + target dir
# var 			moving_dir 		: Vector2 	# direction of moving
# var 			buffered_dir	: Vector2i 	# 
# var 			buffered_cell 	: Vector2i 	#
var 			m_origin_cell 	: Vector2i 	# origin cell that character started moving from

# --- vars about bomber's size and positon ---
var rect_global_position : Vector2i


enum MovementState {
	IDLE,
	MOVING,
	DEAD
}

var movement_state = MovementState.IDLE

func _ready():
	dead = false
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.1
	max_slides = 10
	current_cell = game_area.pos_to_tile_map(global_position)
	game_area.bombers_arr.append(self)
	
func _physics_process(delta: float) -> void:
	if dead:
		die()
		return
	else:
		match movement_state:
			# --- Idle ---
			MovementState.IDLE:
				idle_state()
			# --- Moving ---
			MovementState.MOVING:
				moving_state(delta)
			# --- Put bomb ---
		bombing_state()

func idle_state():
	anim.play("idle")
	target_dir = get_multiple_dir(player_id)
	if target_dir != Vector2i.ZERO:
		movement_state = MovementState.MOVING

# - - - MOVING - - - #
func moving_state(dt: float):
	anim.play("walk")
	var moving_dir := get_multiple_dir(player_id)
	if moving_dir == Vector2i.ZERO:
		movement_state = MovementState.IDLE
		return

	var net_x := moving_dir.x * speed * dt
	var net_y := moving_dir.y * speed * dt
	align_movement(net_x, net_y, dt)

	var next_position := global_position + Vector2(net_x, net_y)
	if can_occupy(next_position):
		global_position = next_position
		current_cell = game_area.pos_to_tile_map(global_position)


func align_movement(net_x: float, net_y: float, dt: float) -> void:
	var grid_pos := game_area.tile_map_to_global(current_cell)
	var diff := grid_pos - global_position
	if diff.length_squared() < 0.0001:
		return

	var f := 1.0 - exp(-15.0 * dt)  

	var w_x := clampf(absf(net_y) / (speed * dt), 0.0, 1.0)
	var w_y := clampf(absf(net_x) / (speed * dt), 0.0, 1.0)

	if w_x > 0.0:
		global_position.x = grid_pos.x if absf(diff.x) < 0.5 else lerp(global_position.x, grid_pos.x, f)
	if w_y > 0.0:
		global_position.y = grid_pos.y if absf(diff.y) < 0.5 else lerp(global_position.y, grid_pos.y, f)

func get_multiple_dir(id : int) -> Vector2i:
	var prefix_id = "bomber"+str(id)
	var input_right : int = int(Input.is_action_pressed(prefix_id+"right"))
	var input_left 	: int = int(Input.is_action_pressed(prefix_id+"left"))
	var input_down 	: int = int(Input.is_action_pressed(prefix_id+"down"))
	var input_up 	: int = int(Input.is_action_pressed(prefix_id+"up"))
	
	var movement_x : int = input_right - input_left
	var movement_y : int = input_down - input_up
	
	if movement_x != 0:
		anim.flip_h = movement_x < 0
		return Vector2i(movement_x, 0)
	if movement_y != 0:
		return Vector2i(0, movement_y)
	return Vector2i(movement_x,movement_y)

func is_target_cell_walkable(target : Vector2i) -> bool:
	var target_cell_source_id = game_area.tile_map_layer.get_cell_source_id(target)
	if game_area.bomb_cells.has(target) or \
	target_cell_source_id == WALL_SOURCE_ID or \
	target_cell_source_id == BOX_SOURCE_ID:
		return false
	return true
# - - - MOVING - - - #
func can_occupy(pos: Vector2) -> bool:
	var half = OFFSET / 2.0
	var epsilon = 0.01

	for x in [-half + epsilon, half - epsilon]:
		for y in [-half + epsilon, half - epsilon]:

			var corner = pos + Vector2(x, y)
			var cell = game_area.pos_to_tile_map(corner)

			if !is_target_cell_walkable(cell):
				return false

	return true


#func get_dir(id : int) -> Vector2i:
	#var desired_dir : Vector2i = Vector2i.ZERO
	##dir =  Input.get_vector("bomber"+str(id)+"left","bomber"+str(id)+"right","bomber"+str(id)+"up","bomber"+str(id)+"down")
	#if Input.is_action_pressed("bomber"+str(id)+"left"):
		#desired_dir = Vector2i.LEFT
		#anim.flip_h = true
	#if Input.is_action_pressed("bomber"+str(id)+"right"):
		#desired_dir = Vector2i.RIGHT
		#anim.flip_h = false
	#if Input.is_action_pressed("bomber"+str(id)+"up"):
		#desired_dir = Vector2i.UP
	#if Input.is_action_pressed("bomber"+str(id)+"down"):
		#desired_dir = Vector2i.DOWN
	#return desired_dir

func put_bomb():
	if bomb_count < max_bombs:
		if !game_area.bomb_cells.has(current_cell):
			anim.play("put")
			var bomba : Node2D = bomb.instantiate()
			bomba.bomber = self
			bomba.global_position = game_area.tile_map_to_global(current_cell)
			bomba.game_area = game_area
			bombs.add_child(bomba)
			# game_area.bomb_cells.append(current_cell)
			bomb_count += 1
		

func die():
	dead = true
	game_area.bombers_arr.erase(self)
	queue_free()
	
func bombing_state():
	if Input.is_action_just_pressed("bomber"+str(player_id)+"bomb"):
		put_bomb()

func ai_move(id : int):
	pass
