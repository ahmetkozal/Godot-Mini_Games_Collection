extends Node2D

const BOX_SOURCE_ID 	: int = 0
const FLOOR_SOURCE_ID 	: int = 1
const WALL_SOURCE_ID 	: int = 2
const BOMB_TIMER 		: float = 7.0
const CENTER_EXPLOSION = preload("res://Objects/bomber/center_explosion.tscn")
const EXPLOSION = preload("res://Objects/bomber/explosion.tscn")
const BOX_EXPLOSION = preload("res://Objects/bomber/box_explosion.tscn")
@onready var bomb_collision: CollisionShape2D = $BombCollision

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

func _ready() -> void:
	tile_map_layer = game_area.tile_map_layer
	timer.wait_time = BOMB_TIMER
	timer.start()
	cell = bomber.current_cell
	cells_to_damage = set_and_get_explosion_area()
	center_explosion_anim.animation_finished.connect(exploded)
	
func set_and_get_explosion_area() -> Array[Vector2i]:
	var explosion_range_array : Array[Vector2i]
	explosion_range = bomber.explosion_range
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

func add_animation(dir : Vector2i,explosion_range_array : Array[Vector2i],explosion, bomb_pos, explosion_cell : Vector2i)->AnimatedSprite2D:
	explosion_range_array.append(explosion_cell)
	var explosion_anim = explosion.instantiate()
	animations.add_child(explosion_anim)
	explosion_anim.global_position = bomb_pos
	explosion_anim.rotation = Vector2(dir).angle()
	explosion_anim.frame = 0
	return explosion_anim

func explode() -> void:
	for i in cells_to_damage:
		if tile_map_layer.get_cell_source_id(i) == BOX_SOURCE_ID:
			game_area.tile_map_layer.set_cell(i,FLOOR_SOURCE_ID,Vector2i(0,0))
			var exploded_box : AnimatedSprite2D = BOX_EXPLOSION.instantiate()
			tile_map_layer.add_child(exploded_box)
			exploded_box.global_position = game_area.tile_map_to_global(i)
			exploded_box.frame = 0
			exploded_box.play()
	kill_in_area(game_area.bombers_arr)
	kill_in_area(game_area.enemies_arr)
	for i in animations.get_children():
		i.play()

func exploded() ->void:
	queue_free()

func kill_in_area(chararcter_arr : Array):
	for i in chararcter_arr:
		if i.current_cell in cells_to_damage:
			i.dead=true

func _on_timer_timeout() -> void:
	var bomb_index : int = game_area.bomb_cells.find(cell)
	if is_instance_valid(bomber):
		bomber.bomb_count -= 1
	if bomb_index > -1:
		game_area.bomb_cells.remove_at(bomb_index)
	explode()


#func _on_area_2d_body_exited(body: Node2D) -> void:
	#print("ACTIVATE COLLISION")
	#print(body)
	#bomb_collision.disabled = false
