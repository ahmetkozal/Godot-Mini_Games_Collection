extends CharacterBody2D

@onready var game_area: GameArea = $"../.."

@export var player_id : int
@export var is_player : bool

const SPEED : float = 60.0
const DEFAULT_BOMB_COOLDOWN: float = 4.0

var current_cell : Vector2i

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
			bomb()
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

func bomb():
	pass

func ai_move(id : int):
	pass
