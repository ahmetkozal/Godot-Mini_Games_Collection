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

const SPEED 					: float = 60.0

var dead 			: bool
var current_cell 	: Vector2i
var target_cell 	: Vector2i
var target_dir 		: Vector2i
var max_bombs 		: int = 1
var bomb_count 		: int = 0
var explosion_range : int = 2
var is_cell_bombed : bool

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
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if dead:
		die()
		return
	else:
		match movement_state:
			MovementState.IDLE:
				anim.play("idle")
				target_dir = get_dir_and_move(player_id)
				if target_dir != Vector2i.ZERO:
					target_cell = current_cell + target_dir
					if is_target_cell_walkable():
						movement_state = MovementState.MOVING
			MovementState.MOVING:
				anim.play("walk")
				global_position = global_position.move_toward(game_area.tile_map_to_global(target_cell),SPEED * delta)
				update_current_cell()
		if Input.is_action_just_pressed("bomber"+str(player_id)+"bomb"):
			put_bomb()

func is_target_cell_walkable() -> bool:
	var target_cell_source_id = game_area.tile_map_layer.get_cell_source_id(target_cell)
	if game_area.bomb_cells.has(target_cell) or target_cell_source_id == WALL_SOURCE_ID or target_cell_source_id == BOX_SOURCE_ID:
		return false
	return true

func update_current_cell():
	if global_position.distance_to(game_area.tile_map_to_global(target_cell)) <= 0.01:
		current_cell = target_cell
		movement_state = MovementState.IDLE

func get_dir_and_move(id : int) -> Vector2i:
	var desired_dir : Vector2i = Vector2i.ZERO
	#dir =  Input.get_vector("bomber"+str(id)+"left","bomber"+str(id)+"right","bomber"+str(id)+"up","bomber"+str(id)+"down")
	if Input.is_action_pressed("bomber"+str(id)+"left"):
		desired_dir = Vector2i.LEFT
		anim.flip_h = true
	if Input.is_action_pressed("bomber"+str(id)+"right"):
		desired_dir = Vector2i.RIGHT
		anim.flip_h = false
	if Input.is_action_pressed("bomber"+str(id)+"up"):
		desired_dir = Vector2i.UP
	if Input.is_action_pressed("bomber"+str(id)+"down"):
		desired_dir = Vector2i.DOWN
	return desired_dir

func put_bomb():
	if bomb_count < max_bombs:
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

func ai_move(id : int):
	pass
