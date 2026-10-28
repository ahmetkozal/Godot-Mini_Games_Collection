extends CharacterBody2D

const CELL_SIZE : int = 16

var k 				: float = 1.0
var base_move_timer : float = 0.50
var move_timer 		: float = 0.0
var dir 			: Vector2
var prev_dir 		: Vector2
var can_input 		: bool

func _ready() -> void:
	dir 		= Vector2.RIGHT
	prev_dir 	= Vector2.LEFT
	can_input 	= true

func _physics_process(delta: float) -> void:
	var move_dir : Vector2= get_dir()
	if move_timer <= 0.0:
		move_timer = 0.0
		position += move_dir * CELL_SIZE
		prev_dir = move_dir
		can_input = true
		move_timer = base_move_timer
	else:
		move_timer -= delta


func get_dir():
	if Input.is_action_just_pressed("down") && prev_dir != Vector2.UP && can_input:
		dir = Vector2.DOWN
		can_input = false
	elif Input.is_action_just_pressed("up") && prev_dir != Vector2.DOWN && can_input:
		dir = Vector2.UP
		can_input = false
	elif Input.is_action_just_pressed("left") && prev_dir != Vector2.RIGHT && can_input:
		dir = Vector2.LEFT
		can_input = false
	elif Input.is_action_just_pressed("right") && prev_dir != Vector2.LEFT && can_input:
		dir = Vector2.RIGHT
		can_input = false
	return dir
	
