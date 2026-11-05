extends Node2D

const BOX_SOURCE_ID 	: int = 0
const FLOOR_SOURCE_ID 	: int = 1
const WALL_SOURCE_ID 	: int = 2

@onready var timer: Timer = $Timer

var dirs 		: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
var bomber 		: CharacterBody2D
var cell 		: Vector2i
var explosion_range 		: int
var tile_map_layer : TileMapLayer

func _ready() -> void:
	tile_map_layer = bomber.game_area.tile_map_layer
	timer.wait_time = bomber.bomb_timer
	timer.start()
	cell = bomber.current_cell
	
	
func set_and_get_explosion_area() -> Array[Vector2i]:
	var explosion_range_array : Array[Vector2i]
	explosion_range = bomber.explosion_range
	explosion_range_array.append(cell)
	for i in dirs:
		for x in range(1,explosion_range+1):
			var explosion_cell : Vector2i = cell+i*x
			var cell_source : int = tile_map_layer.get_cell_source_id(explosion_cell)
			if cell_source == FLOOR_SOURCE_ID:
				explosion_range_array.append(explosion_cell)
			if cell_source == BOX_SOURCE_ID:
					explosion_range_array.append(explosion_cell)
					break
	return explosion_range_array

func explode() -> void:
	queue_free()

func _on_timer_timeout() -> void:
	var bomb_index : int = bomber.game_area.bomb_cells.find(cell)
	bomber.bomb_count -= 1
	if bomb_index > -1:
		bomber.game_area.bomb_cells.remove_at(bomb_index)
	explode()
