extends Node2D

const BOX_SOURCE_ID 	: int = 0
const FLOOR_SOURCE_ID 	: int = 1
const WALL_SOURCE_ID 	: int = 2

const SAFE_ZONE_R 		: int = 1
const BOX_CHANCE		: float = 0.55
const BOMB_UP_CHANCE 	: float = 0.1
const FIRE_UP_CHANCE 	: float = 0.15
const SPEED_UP_CHANCE 	: float = 0.2

@export var bomber_scene : PackedScene

@onready var players: Node2D = $players
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var bomber: CharacterBody2D = $players/Bomber

var player_count 		: int = 1
var safe_zones 			: Array[Vector2i]
var available_cells 	: Array[Vector2i]
var power_up_cells 		: Array[Vector2i]
var player_pos 			: Vector2i
var rng 				: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	player_pos = pos_to_tile_map(bomber.global_position)
	rng.randomize()
	create_safe_zones()
	set_up_enemy_spawn_areas()
	set_up_available_cells()
	place_boxes()
	place_powerups()
	

func instantiate_players() -> void:
	for i in range(0,player_count):
		var bomber = bomber_scene.instantiate()

func set_players_pos() -> void:
	pass

func create_safe_zones() -> void: # Sets up safe zones for player/s
	for x in range(player_pos.x - SAFE_ZONE_R,player_pos.x + SAFE_ZONE_R + 1):
		for y in range(player_pos.y - SAFE_ZONE_R,player_pos.y + SAFE_ZONE_R + 1):
			safe_zones.append(Vector2i(x,y))

func set_up_enemy_spawn_areas() -> void:
	pass

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

func place_powerups() -> void:
	pass

# Converts a global position (world coordinates) into TileMapLayer cell coordinates.
# First transforms the position into the TileMapLayer's local coordinate space,
# then converts it into a grid cell position.
func pos_to_tile_map(pos : Vector2) -> Vector2i:
	return tile_map_layer.local_to_map(tile_map_layer.to_local(pos))

# Converts TileMapLayer cell coordinates into a global world position.
# First converts the cell coordinates into local pixel coordinates,
# then transforms the position into global coordinates.
func tile_map_to_global(cell : Vector2i) -> Vector2:
	return tile_map_layer.to_global(tile_map_layer.map_to_local(cell))
