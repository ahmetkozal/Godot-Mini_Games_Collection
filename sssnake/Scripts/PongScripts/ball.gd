extends CharacterBody2D

const BOUNCE_STR 		: float 	= 0.8 # aciyi yumusatmak icin
const BALL_SPEED_K 		: float 	= 1.025
const PADDLE_SPEED_K 	: float = 1.01
const default_speed 	: float = 300.0

var speed 			: float = default_speed
var start_dir 		: Vector2 = Vector2.RIGHT
var dir 			: Vector2
var game_start 		: bool = false

func _ready() -> void:
	dir = start_dir.normalized()
	
func _physics_process(_delta: float) -> void:
	if game_start:
		ball_move()
		
	move_and_slide()
	calc_collision()

func ball_move() -> void:
	velocity = speed * dir.normalized()
	
func _on_timer_timeout() -> void:
	game_start = true
	

func calc_collision() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is CharacterBody2D:
			if dir.dot(collision.get_normal()) < 0: # <0 means it is moving towards to the object
				dir = bounce_from_paddle(collider)
				speed *= BALL_SPEED_K
				collider.move_speed *= PADDLE_SPEED_K
		elif collider is StaticBody2D:
			if dir.dot(collision.get_normal()) < 0: 
				dir.y *= -1

#func bounce_from_wall() :
	#pass

func bounce_from_paddle(collider) -> Vector2:
	var bounce_dir 		: Vector2
	var ball_y 			: float
	var paddle_y 		: float
	var paddle_height	: float
	var offset 			: float
	var normalized 		: float
	
	ball_y 			= position.y
	paddle_y 		= collider.position.y
	paddle_height 	= collider.get_node("CollisionShape2D").shape.size.y
	
	offset 			= ball_y - paddle_y
	normalized 		= offset / (paddle_height / 2.0)
	
	dir.x *= -1
	dir.y = normalized * BOUNCE_STR
	
	bounce_dir = dir.normalized()
	#print("Ball: ", position.y)
	#print("Collision: ", collision.get_position().y)
	#print("Paddle: ", collider.global_position.y)
	
	return bounce_dir
