class_name GameArea
extends Node2D

const BOX_SOURCE_ID 	: int = 0
const FLOOR_SOURCE_ID 	: int = 1
const WALL_SOURCE_ID 	: int = 2

const SAFE_ZONE_R 		: int = 2
const BOX_CHANCE		: float = 0.45
const BOMB_UP_CHANCE 	: float = 0.1
const FIRE_UP_CHANCE 	: float = 0.15
const SPEED_UP_CHANCE 	: float = 0.2

@export var bomber_scene : PackedScene
@export var enemy_scene : PackedScene
@onready var players: Node2D = $players
@onready var enemies: Node2D = $enemies
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

var game_area 			: Rect2i
var bomber_safe_zones 	: Array[Vector2i]
var enemy_spawn_areas 	: Array[Rect2i]
var enemy_safe_zones 	: Array[Vector2i]
var enemy_spawn_points 	: Array[Vector2i]
var available_cells 	: Array[Vector2i]
var floor_cells 		: Array[Vector2i]
var box_cells 			: Array[Vector2i]
var power_up_cells 		: Array[Vector2i]

var rng 				: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	game_area = tile_map_layer.get_used_rect()
	print(game_area)
	
	# setting up game area
	rng.randomize()
	create_safe_zones() # Creating safe zones to leave empty cells
	set_up_enemy_spawn_areas() # divides map to 8 pieces to determenine enemy spawn points
	get_floor_cells() # get all floors position into an array
	spawn_enemies() 
	create_enemy_safe_zones()
	set_up_available_cells()
	place_boxes()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://UI/game_select_menu.tscn")

#func instantiate_players() -> void:
	#for i in range(0,player_count):
		#var new_bomber = bomber_scene.instantiate()
		#new_bomber.player_id = i
		#new_bomber.name = "bomber"+str(i)
		#players.add_child(new_bomber)

func create_safe_zones() -> void: # Sets up safe zones for player/s
	var player_pos 			: Vector2i
	for i : CharacterBody2D in players.get_children():
		player_pos = pos_to_tile_map(i.global_position)
		for x in range(player_pos.x - SAFE_ZONE_R,player_pos.x + SAFE_ZONE_R + 1):
			for y in range(player_pos.y - SAFE_ZONE_R,player_pos.y + SAFE_ZONE_R + 1):
				bomber_safe_zones.append(Vector2i(x,y))

func get_floor_cells() -> void:
	for i in tile_map_layer.get_used_cells():
		if tile_map_layer.get_cell_source_id(i) == FLOOR_SOURCE_ID:
			floor_cells.append(i)

func set_up_enemy_spawn_areas() -> void:
	enemy_spawn_areas.append(Rect2i(Vector2i(1,3),Vector2i(7,3)))
	enemy_spawn_areas.append(Rect2i(Vector2i(1,6),Vector2i(7,3)))
	enemy_spawn_areas.append(Rect2i(Vector2i(1,9),Vector2i(7,3)))
	
	enemy_spawn_areas.append(Rect2i(Vector2i(11,3),Vector2i(7,3)))
	enemy_spawn_areas.append(Rect2i(Vector2i(11,6),Vector2i(7,3)))
	enemy_spawn_areas.append(Rect2i(Vector2i(11,9),Vector2i(7,3)))
	
	enemy_spawn_areas.append(Rect2i(Vector2i(9,1),Vector2i(1,13)))
	enemy_spawn_areas.append(Rect2i(Vector2i(10,1),Vector2i(1,13)))

func spawn_enemies() -> void:
	for i : Rect2i in enemy_spawn_areas:
		var available_for_enemy : Array[Vector2i] # Creates an empty array for every enemy
		for cells in floor_cells:
			if i.has_point(cells):
				if cells not in bomber_safe_zones:
					available_for_enemy.append(cells)
		if available_for_enemy.size() > 0:
			var enemy : Area2D = enemy_scene.instantiate()
			var random_pos : Vector2i = available_for_enemy[randi_range(0,available_for_enemy.size()-1)]
			#var random_pos : Vector2i = Vector2i(randi_range(i.position.x,i.end.x-1),randi_range(i.position.y,i.end.y-1))
			enemy.global_position = tile_map_to_global(random_pos)
			enemies.add_child(enemy)
			enemy_spawn_points.append(random_pos)


func create_enemy_safe_zones() -> void:
	for i in enemy_spawn_points:
			enemy_safe_zones.append(i - Vector2i(1,0))
			enemy_safe_zones.append(i)
			enemy_safe_zones.append(i + Vector2i(1,0))
			enemy_safe_zones.append(i - Vector2i(0,1))
			enemy_safe_zones.append(i + Vector2i(0,1))

func set_up_available_cells() -> void: # Setting up available cells
	for i in floor_cells:
		if i not in bomber_safe_zones and i not in enemy_safe_zones:
			available_cells.append(i)

func place_boxes() -> void: # Places boxes randomly at available cells
	for i in available_cells:
		var random_number = rng.randf()
		if random_number <= BOX_CHANCE:
			tile_map_layer.set_cell(i,BOX_SOURCE_ID,Vector2i(0,0))
			box_cells.append(i)

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
