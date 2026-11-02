extends Node2D

const BOX_SOURCE_ID 	: int = 0
const FLOOR_SOURCE_ID 	: int = 1
const WALL_SOURCE_ID 	: int = 2

const SAFE_ZONE_R 		: int = 1
const BOX_CHANCE		: float = 0.55

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var bomber: CharacterBody2D = $Bomber

var safe_zones 			: Array[Vector2i]
var available_cells 	: Array[Vector2i]
var player_pos 			: Vector2i
var rng					= RandomNumberGenerator.new()

func _ready() -> void:
	player_pos = tile_map_layer.local_to_map(tile_map_layer.to_local(bomber.global_position))
	rng.randomize()
	create_safe_zones()
	set_up_available_cells()
	place_boxes()


func create_safe_zones() -> void: # Sets up safe zones for player/s
	for x in range(player_pos.x - SAFE_ZONE_R,player_pos.x + SAFE_ZONE_R + 1):
		for y in range(player_pos.y - SAFE_ZONE_R,player_pos.y + SAFE_ZONE_R + 1):
			safe_zones.append(Vector2i(x,y))

func set_up_available_cells() -> void: # Setting up available cells
	for i in tile_map_layer.get_used_cells():
		if tile_map_layer.get_cell_source_id(i) == FLOOR_SOURCE_ID:
			if i not in safe_zones:
				available_cells.append(i)

func place_boxes() -> void: # Places boxes randomly at available cells
	for i in available_cells:
		var random_number = rng.randf()
		if random_number <= BOX_CHANCE:
			tile_map_layer.set_cell(i,BOX_SOURCE_ID,Vector2i(0,0))

func set_up_enemy_spawn_areas() -> void:
	pass
