class_name BombObject
extends StaticBody2D

const BOX_SOURCE_ID 	: int = 0
const FLOOR_SOURCE_ID 	: int = 1
const WALL_SOURCE_ID 	: int = 2
const BOMB_TIMER 		: float = 2.0
const CENTER_EXPLOSION 	= preload("res://Objects/bomber/center_explosion.tscn")
const EXPLOSION 		= preload("res://Objects/bomber/explosion.tscn")
const BOX_EXPLOSION 	= preload("res://Objects/bomber/box_explosion.tscn")

const POWERUP_CHANCE 	: float = 0.3
const MAX_RANGE_CHANCE 	: float = 0.1
const MAX_BOMB_CHANCE 	: float = 0.3
const FIRE_RANGE_CHANCE : float = 0.6
const SKATE_CHANCE 		: float = 1.0




const POWERUP_FIRE = preload("res://Objects/bomber/powerup_fire.tscn")
const POWERUP_FULLFIRE = preload("res://Objects/bomber/powerup_fullfire.tscn")
const POWERUP_SKATE = preload("res://Objects/bomber/powerup_skate.tscn")
const POWERUP_MAXBOMBS = preload("res://Objects/bomber/powerup_maxbombs.tscn")


@onready var animations: Node2D = $animations
@onready var timer: Timer = $Timer

var game_area 				: GameArea
var dirs 					: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
var bomber 					: CharacterBody2D
var cell 					: Vector2i
var explosion_range 		: int
var tile_map_layer 			: TileMapLayer
var center_explosion_anim 	: AnimatedSprite2D
var cells_to_damage 		: Array[Vector2i]
var col_active 				: bool = false
var has_exploded 				: bool = false

var rng 					: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	tile_map_layer = game_area.tile_map_layer
	timer.wait_time = BOMB_TIMER
	timer.start()

	cell = bomber.current_cell
	game_area.bomb_cells_enemy.append(cell)
	explosion_range = bomber.explosion_range
	
	
func set_and_get_explosion_area() -> Array[Vector2i]:
	var explosion_range_array : Array[Vector2i]
	center_explosion_anim = add_animation(Vector2i.ZERO,explosion_range_array,CENTER_EXPLOSION,global_position,cell)
	for i in dirs:
		for x in range(1,explosion_range+1):
			var explosion_cell : Vector2i = cell+i*x
			var cell_source : int = tile_map_layer.get_cell_source_id(explosion_cell)
			if cell_source == WALL_SOURCE_ID:
				break
			else:
				add_animation(i,explosion_range_array, EXPLOSION,game_area.tile_map_to_global(explosion_cell),explosion_cell)
				if cell_source == BOX_SOURCE_ID:
					break
	return explosion_range_array


func add_animation(dir: Vector2i, explosion_range_array: Array[Vector2i], explosion, bomb_pos: Vector2, explosion_cell: Vector2i) -> AnimatedSprite2D:
	explosion_range_array.append(explosion_cell)

	var explosion_anim: AnimatedSprite2D = explosion.instantiate()
	animations.add_child(explosion_anim)

	explosion_anim.global_position = bomb_pos
	explosion_anim.rotation = Vector2(dir).angle()
	explosion_anim.frame = 0

	var area: Area2D = explosion_anim.get_node("Area2D")

	return explosion_anim


func explode() -> void:
	if has_exploded:
		return
	has_exploded = true
	cells_to_damage = set_and_get_explosion_area()
	center_explosion_anim.animation_finished.connect(exploded)

	for explosion_anim in animations.get_children():
		var area: Area2D = explosion_anim.get_node("Area2D")

	for i in cells_to_damage:
		if tile_map_layer.get_cell_source_id(i) == BOX_SOURCE_ID:
			explode_box(i)
			spawn_powerup(i)

	kill_in_area(game_area.bombers_arr)
	kill_in_area(game_area.enemies_arr)

	for explosion_anim in animations.get_children():
		explosion_anim.play()


func explode_box(pos : Vector2i):
	game_area.tile_map_layer.set_cell(pos,FLOOR_SOURCE_ID,Vector2i(0,0))
	var exploded_box : AnimatedSprite2D = BOX_EXPLOSION.instantiate()
	tile_map_layer.add_child(exploded_box)
	exploded_box.global_position = game_area.tile_map_to_global(pos)
	exploded_box.frame = 0
	exploded_box.play()

func spawn_powerup(pos : Vector2i):
	var random_number = rng.randf()
	if random_number <= POWERUP_CHANCE:
		var rnd = rng.randf()
		var powerup_obj
		if rnd <= MAX_RANGE_CHANCE:
			powerup_obj = POWERUP_FULLFIRE.instantiate()
		elif rnd <= MAX_BOMB_CHANCE:
			powerup_obj = POWERUP_MAXBOMBS.instantiate()
		elif rnd <= FIRE_RANGE_CHANCE:
			powerup_obj = POWERUP_FIRE.instantiate()
		elif rnd <= SKATE_CHANCE:
			powerup_obj = POWERUP_SKATE.instantiate()
		powerup_obj.global_position = game_area.tile_map_to_global(pos)
		game_area.powerups.add_child(powerup_obj)

func exploded() ->void:
	queue_free()

func kill_in_area(chararcter_arr : Array):
	for i in chararcter_arr:
		if i.current_cell in cells_to_damage:
			i.dead=true

func _on_timer_timeout() -> void:
	var bomb_index : int = game_area.bomb_cells.find(cell)
	var bomb_index_enemy : int = game_area.bomb_cells_enemy.find(cell)
	if is_instance_valid(bomber):
		bomber.bomb_count -= 1
	if bomb_index > -1:
		game_area.bomb_cells.remove_at(bomb_index)
	if bomb_index_enemy > -1:
		game_area.bomb_cells_enemy.remove_at(bomb_index_enemy)
	explode.call_deferred()


func _on_area_2d_body_exited(_body: Node2D) -> void:
	print("ACTIVATE COLLISION")
	# print(body.player_id)
	var bomb_vec : Vector2i = game_area.pos_to_tile_map(global_position)
	if !game_area.bomb_cells.has(bomb_vec):
		game_area.bomb_cells.append(game_area.pos_to_tile_map(global_position))


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("CHAIN")
	explode.call_deferred()
