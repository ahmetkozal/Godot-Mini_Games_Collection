extends Node2D

const MAX_SCORE : int = 1

@export var timer				: Timer
@export var timer_label 		: Label
@export var ball 				: CharacterBody2D
@export var paddle1 			: CharacterBody2D
@export var paddle2				: CharacterBody2D
@export var winner_label		: RichTextLabel

@export var player1_score_label : Label
@export var player2_score_label : Label

var ball_default_pos 	: Vector2
var player1_default_pos : Vector2
var player2_default_pos : Vector2

var player1_score 		: int
var player2_score 		: int

var game_end : bool = false

func _ready() -> void:
	ball_default_pos 	= ball.position
	player1_default_pos = paddle1.position
	player2_default_pos = paddle2.position
	player1_score = 0
	player2_score = 0

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://UI/game_select_menu.tscn")
	if game_end:
		if Input.is_action_just_pressed("boost") or Input.is_joy_button_pressed(0,JOY_BUTTON_A) or Input.is_joy_button_pressed(1,JOY_BUTTON_A):
			get_tree().reload_current_scene()



func _on_player_1_gate_body_entered(_body: Node2D) -> void:
	add_score_to_winner(2)

func _on_player_2_gate_2_body_entered(_body: Node2D) -> void:
	add_score_to_winner(1)

func add_score_to_winner(winner : int) -> void:
	if winner == 1:
		player1_score += 1
	else:
		player2_score += 1
	update_label(player1_score,player1_score_label)
	update_label(player2_score,player2_score_label)
	if player1_score >= MAX_SCORE:
		winner_label.text = "[rainbow]Player 1 Win!"
		game_end = true
	elif player2_score >= MAX_SCORE:
		winner_label.text = "[rainbow]Player 2 Win!"
		game_end = true
	if not game_end:
		restart_the_game()

func update_label(score: int, label : Label):
	label.text = str(score)

func restart_the_game() -> void:
	restart_player(paddle1,player1_default_pos)
	restart_player(paddle2,player2_default_pos)
	restart_ball(ball_default_pos)
	
	timer.wait_time 	= 3.0
	timer.start()
	timer_label.show()

func restart_player(player : CharacterBody2D, default_pos : Vector2) -> void:
	player.position = default_pos
	player.move_speed = player.DEFAULT_PADDLE_SPEED

func restart_ball(default_pos : Vector2) -> void:
	ball.position 	= default_pos
	ball.speed = 0
	if player1_score >= player2_score:
		ball.dir = Vector2.RIGHT
	else:
		ball.dir = Vector2.LEFT
