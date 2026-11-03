extends Area2D

const BOX_SOURCE_ID 	: int = 0
const FLOOR_SOURCE_ID 	: int = 1
const WALL_SOURCE_ID 	: int = 2
const OFFSET 			: Vector2i = Vector2i(16,16)

@onready var game_area = $"../.."

const SPEED 		: float = 40.0
const WAIT_TIME 	: float = 2.0

var tile_map_layer 	: TileMapLayer
var dir 			: Vector2i
var current_cell 	: Vector2i

func _ready() -> void:
	tile_map_layer = game_area.tile_map_layer
	dir = Vector2i.DOWN

func _physics_process(delta: float) -> void:
	move(delta)
	check_neighbour_cells()

func move(dt: float) -> void:
	global_position = global_position.move_toward(Vector2i.ZERO+OFFSET,SPEED * dt)
	current_cell = game_area.pos_to_tile_map(global_position)

func get_next_target() -> Vector2i:
	var next_target: Vector2i
	return next_target

func check_neighbour_cells() -> void:
	var next_cell : Vector2i = current_cell + dir
	if tile_map_layer.get_cell_source_id(next_cell) == BOX_SOURCE_ID or tile_map_layer.get_cell_source_id(next_cell) == WALL_SOURCE_ID:
		pass
	
