extends CharacterBody2D

const DEFAULT_PADDLE_SPEED : float = 400

@export var player_id 	: int = 0
@export var is_player	: bool

#var connected_gamepads: Array = Input.get_connected_joypads()
#var gamepad_count: int = connected_gamepads.size()

var move_speed : float = 400.0

func _ready() -> void:
	move_speed = DEFAULT_PADDLE_SPEED
	#print("Connected gamepads: ", gamepad_count)

func _physics_process(_delta: float) -> void:
	if Input.is_joy_button_pressed(1,JOY_BUTTON_A) or Input.is_action_just_pressed("Player2Down") or Input.is_action_just_pressed("Player2Up"):
		is_player = true
	if is_player:
		move_input()
	else:
		ai_input()
	move_and_slide()

func move_input() -> void:
	var direction := 0.0
	
	# keyboard
	if player_id == 0:
		direction = Input.get_axis("Player1Up", "Player1Down")
	elif player_id == 1:
		direction = Input.get_axis("Player2Up", "Player2Down")

	# gamepad
	if Input.is_joy_button_pressed(player_id, JOY_BUTTON_DPAD_UP):
		direction = -1.0
	elif Input.is_joy_button_pressed(player_id, JOY_BUTTON_DPAD_DOWN):
		direction = 1.0
	
	velocity.y = direction * move_speed

func ai_input() -> void:
	pass
