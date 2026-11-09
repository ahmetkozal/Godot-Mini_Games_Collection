extends CharacterBody2D

# --- vars about game area ---
const 			BOX_EXPLOSION 	= preload("res://Objects/bomber/box_explosion.tscn") 	# Box explosin animation
const 			BOX_SOURCE_ID 	: int = 	0 											# Source id of box in tile set
const 			FLOOR_SOURCE_ID : int = 	1 											# Source id of floor in tile set
const 			WALL_SOURCE_ID 	: int = 	2 											# Source id of wall in tile set
const 			OFFSET 			: int = 	32 											# Grid size actually
@onready var 	game_area		: GameArea = $"../.." 									# game_area scene to get get data about game

# --- vars about player ---
@onready var 	anim 		: AnimatedSprite2D = $AnimatedSprite2D 	# bomber animations
@export var 	player_id 	: int 									# player id is used for taking correct input
@export var 	is_player 	: bool 									# is bomber human controlled or ai
const 			SPEED 		: float = 70.0 							# bomber speed
var 			dead 		: bool				 					# dead

# --- vars about bombs ---
@onready var 	bombs				: Node2D = $"../../bombs" 	# game scene object to collect bombs
@export var 	bomb 				: PackedScene				# bomb scene
var 			is_cell_bombed 		: bool						# if target cell is bombed
var 			max_bombs 			: int = 1					# how many bomb/s can player plant
var 			bomb_count 			: int = 0					# how many bomb/s player planted
var 			explosion_range 	: int = 2					# explosion radius

# --- vars about navigation and movement ---
var 			current_cell 	: Vector2i 	# bomber's current cell
var 			target_dir 		: Vector2i 	# taking input and setting direction
var 			target_cell 	: Vector2i 	# bomber's current cell + target dir
# var 			moving_dir 		: Vector2 	# direction of moving
# var 			buffered_dir	: Vector2i 	# 
# var 			buffered_cell 	: Vector2i 	#
var 			net_x 			: float 	# exact pixel characted moved in x
var 			net_y 			: float 	# exact pixel characted moved in y
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
		m_origin_cell =  current_cell
		movement_state = MovementState.MOVING

# - - - MOVING - - - #
func moving_state(dt : float):
	anim.play("walk")
	current_cell = game_area.pos_to_tile_map(global_position)
	var moving_dir : Vector2i = get_multiple_dir(player_id)
	if moving_dir == Vector2i.ZERO:
		movement_state = MovementState.IDLE
		return
	target_dir = get_multiple_dir(player_id)
	var normalized_dir = Vector2(moving_dir).normalized()
	net_x = global_position.x + normalized_dir.x * SPEED * dt
	net_y = global_position.y + normalized_dir.y * SPEED * dt
	if !is_movement_blocked(moving_dir,current_cell+moving_dir):
		global_position += normalized_dir * SPEED * dt

func get_multiple_dir(id : int) -> Vector2i:
	var desired_dir 	: Vector2i
	var input_right : int = int(Input.is_action_pressed("bomber"+str(id)+"right"))
	var input_left 	: int = int(Input.is_action_pressed("bomber"+str(id)+"left"))
	var input_down 	: int = int(Input.is_action_pressed("bomber"+str(id)+"down"))
	var input_up 	: int = int(Input.is_action_pressed("bomber"+str(id)+"up"))
	
	var movement_x : int = input_right - input_left
	var movement_y : int = input_down - input_up
	
	if input_right < input_left:
		anim.flip_h = true
	elif input_right > input_left:
		anim.flip_h = false
	desired_dir = Vector2i(movement_x,movement_y)
	return desired_dir

func is_movement_blocked(m_dir : Vector2i, t_cell : Vector2i) -> bool:
	if is_target_cell_walkable(t_cell):
		return false
	else:
		if m_dir == Vector2i.RIGHT 	and (game_area.tile_map_to_global(t_cell).x - OFFSET - net_x < 0.01):
			return true
		if m_dir == Vector2i.LEFT 	and (game_area.tile_map_to_global(t_cell).x + OFFSET - net_x > 0.01):
			return true
		if m_dir == Vector2i.DOWN 	and (game_area.tile_map_to_global(t_cell).y - OFFSET - net_y < 0.01):
			return true
		if m_dir == Vector2i.UP 	and (game_area.tile_map_to_global(t_cell).y + OFFSET - net_y > 0.01):
			return true
		else: return false

func is_target_cell_walkable(target : Vector2i) -> bool:
	var target_cell_source_id = game_area.tile_map_layer.get_cell_source_id(target)
	if game_area.bomb_cells.has(target) or target_cell_source_id == WALL_SOURCE_ID or target_cell_source_id == BOX_SOURCE_ID:
		return false
	return true
# - - - MOVING - - - #


func update_current_cell():
	if global_position.distance_to(game_area.tile_map_to_global(target_cell)) <= 0.01:
		current_cell = target_cell
		movement_state = MovementState.IDLE



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
		anim.play("put")
		var bomba : Node2D = bomb.instantiate()
		bomba.bomber = self
		bomba.global_position = game_area.tile_map_to_global(current_cell)
		bomba.game_area = game_area
		bombs.add_child(bomba)
		game_area.bomb_cells.append(current_cell)
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
