extends Camera2D
# copied from this reddit post
# https://www.reddit.com/r/godot/comments/17e8s6f/screencamera_shake_2dgodot_4/
@export var decay := 0.8 #How quickly shaking will stop [0,1].
@export var max_offset := Vector2(100,75) #Maximum displacement in pixels.
@export var max_roll = 0.0 #Maximum rotation in radians (use sparingly).
@export var noise : FastNoiseLite #The source of random values.

var noise_y = 0 #Value used to move through the noise

var trauma := 0.0 #Current shake strength
var trauma_pwr := 3 #Trauma exponent. Use [2,3]
func _ready():
	randomize()
	noise.seed = randi()

func add_trauma(amount : float):
	trauma = min(trauma + amount, 1.0)
	
func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
		#optional
	elif offset.x != 0 or offset.y != 0 or rotation != 0:
		lerp(offset.x,0.0,1)
		lerp(offset.y,0.0,1)
		lerp(rotation,0.0,1)

func shake(): 
	var amt = pow(trauma, trauma_pwr)
	noise_y += 1
	rotation = max_roll * amt * noise.get_noise_2d(noise.seed,noise_y)
	offset.x = max_offset.x * amt * noise.get_noise_2d(noise.seed*2,noise_y)
	offset.y = max_offset.y * amt * noise.get_noise_2d(noise.seed*3,noise_y)


func _on_area_2d_body_entered(body: Node2D) -> void:
	trauma = 1.2
	if trauma:
		trauma = max(trauma - decay, 0)
		shake()
		#optional
	elif offset.x != 0 or offset.y != 0 or rotation != 0:
		lerp(offset.x,0.0,1)
		lerp(offset.y,0.0,1)
		lerp(rotation,0.0,1)
