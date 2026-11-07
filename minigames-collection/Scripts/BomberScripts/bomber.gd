extends CharacterBody2D

const BOX_EXPLOSION = preload("res://Objects/bomber/box_explosion.tscn")
const BOX_SOURCE_ID 	: int = 0
const FLOOR_SOURCE_ID 	: int = 1
const WALL_SOURCE_ID 	: int = 2

@onready var game_area	: GameArea = $"../.."
@onready var bombs		: Node2D = $"../../bombs"
@onready var anim 		: AnimatedSprite2D = $AnimatedSprite2D

@export var bomb : PackedScene
@export var player_id : int
@export var is_player : bool

const SPEED 					: float = 70.0

var dead 			: bool
var current_cell 	: Vector2i
var target_cell 	: Vector2i
var target_dir 		: Vector2i
var moving_dir 		: Vector2
var buffered_dir	: Vector2i
var buffered_cell 	: Vector2i
var max_bombs 		: int = 1
var bomb_count 		: int = 0
var explosion_range : int = 2
var is_cell_bombed 	: bool
var net_x 			: float
var net_y 			: float
var m_origin_cell 	: Vector2i

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

func moving_state(dt : float):
	anim.play("walk")
	var not_normalized_dir : Vector2i
	not_normalized_dir = get_multiple_dir(player_id)
	moving_dir = Vector2(not_normalized_dir).normalized()
	if moving_dir == Vector2.ZERO:
		movement_state = MovementState.IDLE
		return
	if !is_movement_blocked(not_normalized_dir, Vector2i(m_origin_cell)+not_normalized_dir):
		net_x = (global_position + moving_dir * SPEED * dt).x
		net_y = (global_position + moving_dir * SPEED * dt).y
		global_position += moving_dir * SPEED * dt
		current_cell = game_area.pos_to_tile_map(global_position)
	if global_position.x > game_area.tile_map_to_global(Vector2(m_origin_cell)).x:
		m_origin_cell = current_cell

func is_movement_blocked(m_dir : Vector2i, t_cell : Vector2i) -> bool:
	# caprazlar
	if m_dir.x != 0 and m_dir.y != 0:
		if is_target_cell_walkable(m_origin_cell + m_dir) and is_target_cell_walkable(m_origin_cell+Vector2i(m_dir.x,0)):
			return false
		else:
			return true
			
	if is_target_cell_walkable(t_cell):
		return false
	if m_dir == Vector2i.RIGHT and (game_area.tile_map_to_global(t_cell).x - 32 - net_x < 0.01):
		return true
	if m_dir == Vector2i.LEFT and (game_area.tile_map_to_global(t_cell).x + 32 - net_x > 0.01):
		return true
	if m_dir == Vector2i.DOWN and (game_area.tile_map_to_global(t_cell).y - 32 - net_y < 0.01):
		return true
	if m_dir == Vector2i.UP and (game_area.tile_map_to_global(t_cell).y + 32 - net_y > 0.01):
		return true
	else: return false

func is_target_cell_walkable(target : Vector2i) -> bool:
	var target_cell_source_id = game_area.tile_map_layer.get_cell_source_id(target)
	if game_area.bomb_cells.has(target) or target_cell_source_id == WALL_SOURCE_ID or target_cell_source_id == BOX_SOURCE_ID:
		return false
	return true

func update_current_cell():
	if global_position.distance_to(game_area.tile_map_to_global(target_cell)) <= 0.01:
		current_cell = target_cell
		movement_state = MovementState.IDLE

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
		

func die()->void:
	var self_index : int = game_area.bombers_arr.find(self)
	if self_index >-1:
		game_area.bombers_arr.remove_at(self_index)
	queue_free()

func bombing_state():
	if Input.is_action_just_pressed("bomber"+str(player_id)+"bomb"):
		put_bomb()

func ai_move(id : int):
	pass
