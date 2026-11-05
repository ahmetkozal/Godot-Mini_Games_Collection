extends CharacterBody2D

@onready var game_area	: GameArea = $"../.."
@onready var bombs		: Node2D = $"../../bombs"
@onready var anim 		: AnimatedSprite2D = $AnimatedSprite2D

@export var bomb : PackedScene
@export var player_id : int
@export var is_player : bool

const SPEED 					: float = 60.0

var dead 			: bool
var current_cell 	: Vector2i
var max_bombs 		: int = 1
var bomb_count 		: int = 0
var bomb_timer 		: float = 3.0
var explosion_range : int = 2

func _ready():
	dead = false
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.1
	max_slides = 10
	game_area.bombers_arr.append(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if dead:
		die()
		return
	else:
		if is_player:
			velocity = get_dir_and_move(player_id) * SPEED
			if Input.is_action_just_pressed("bomber"+str(player_id)+"bomb"):
				put_bomb()
		else:
			ai_move(player_id)
		move_and_slide()
		current_cell = game_area.pos_to_tile_map(global_position)
		if velocity == Vector2.ZERO:
			anim.play("idle")
		else:
			anim.play("walk")

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
