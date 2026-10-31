extends CharacterBody2D

@export var player_id 	: int = 0
@export var is_player	: bool

const MOVE_SPEED : float 	= 400.0
#const MAX_SPEED : float 	= 500.0

func _physics_process(delta: float) -> void:
	if is_player:
		move_input()
	else:
		ai_input()
	move_and_slide()


func move_input() -> void:
	var direction := 0.0
	
	# keyboard
	if player_id == 0:
		direction = Input.get_axis("up", "down")
	elif player_id == 1:
		direction = Input.get_axis("ui_up", "ui_down")

	# gamepad
	if Input.is_joy_button_pressed(player_id, JOY_BUTTON_DPAD_UP):
		direction = -1.0
	elif Input.is_joy_button_pressed(player_id, JOY_BUTTON_DPAD_DOWN):
		direction = 1.0

	velocity.y = direction * MOVE_SPEED

func ai_input() -> void:
	pass
