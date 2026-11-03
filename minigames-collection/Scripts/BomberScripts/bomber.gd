extends CharacterBody2D

const SPEED : float = 60.0

@export var player_id : int
@export var is_player : bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if is_player:
		velocity = get_dir_and_move(player_id) * SPEED
		print(velocity)
	else:
		ai_move(player_id)
	move_and_slide()

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

func center_bomber() -> void:
	pass

func ai_move(id : int):
	pass
