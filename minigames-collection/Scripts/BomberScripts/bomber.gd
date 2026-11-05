extends CharacterBody2D

@onready var game_area: GameArea = $"../.."
@onready var bombs: Node2D = $"../../bombs"

@export var bomb : PackedScene
@export var player_id : int
@export var is_player : bool

const SPEED 					: float = 60.0

var current_cell 	: Vector2i
var max_bombs 		: int = 1
var bomb_count 		: int = 0
var bomb_timer 		: float = 3.0
var explosion_range : int = 1

func _ready():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.1
	max_slides = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if is_player:
		velocity = get_dir_and_move(player_id) * SPEED
		if Input.is_action_just_pressed("bomber"+str(player_id)+"bomb"):
			print("BOMBED")
			put_bomb()
	else:
		ai_move(player_id)
	move_and_slide()
	current_cell = game_area.pos_to_tile_map(global_position)
	

func get_dir_and_move(id : int) -> Vector2i:
	var desired_dir : Vector2i = Vector2i.ZERO
	#dir =  Input.get_vector("bomber"+str(id)+"left","bomber"+str(id)+"right","bomber"+str(id)+"up","bomber"+str(id)+"down")
	if Input.is_action_pressed("bomber"+str(id)+"left"):
		desired_dir = Vector2i.LEFT
	if Input.is_action_pressed("bomber"+str(id)+"right"):
		desired_dir = Vector2i.RIGHT
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
		bombs.add_child(bomba)
		game_area.bomb_cells.append(current_cell)
		bomb_count += 1
		print(game_area.bomb_cells)

func ai_move(id : int):
	pass
