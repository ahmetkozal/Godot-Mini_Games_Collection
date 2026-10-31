extends CharacterBody2D


const SPEED = 300.0

var start_dir 	: Vector2 = Vector2.RIGHT
var dir 		: Vector2
var game_start 	: bool = false

func _ready() -> void:
	dir = start_dir.normalized()

func _physics_process(delta: float) -> void:
	if game_start:
		ball_move(dir.normalized())
		
	move_and_slide()
	calc_collision()

func ball_move(dir) -> void:
	velocity = SPEED * dir
	
func _on_timer_timeout() -> void:
	game_start = true
	

func calc_collision() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		# CharacterBody2D StaticBody2D
		if collider is CharacterBody2D:
			if dir.dot(collision.get_normal()) < 0: # <0 means it is moving towards to the object
				dir.x *= -1
		elif collider is StaticBody2D:
			pass
