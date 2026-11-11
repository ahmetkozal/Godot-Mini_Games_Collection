extends Area2D

const BOX_SOURCE_ID 	: int = 0
const FLOOR_SOURCE_ID 	: int = 1
const WALL_SOURCE_ID 	: int = 2
const SPEED 			: float = 50.0
const WAIT_TIME 		: float = 1.0
const PATROL_DISTANCE 	: int = 5

@onready var game_area = $"../.."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var dead 			: bool
var remaining_cell 	: int
var can_move 		: bool = true
var time 			: float = 0.0
var tile_map_layer 	: TileMapLayer
var dir 			: Vector2i
var current_cell 	: Vector2i
var target_cell 	: Vector2i
var dirs 			: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

func _ready() -> void:
	dead 			= false
	remaining_cell 	= PATROL_DISTANCE
	tile_map_layer 	= game_area.tile_map_layer
	current_cell 	= game_area.pos_to_tile_map(global_position)
	dir				 = get_new_dir()
	target_cell 	= current_cell + dir
	game_area.enemies_arr.append(self)


func _physics_process(delta: float) -> void:
	if dead:
		var self_index : int = game_area.enemies_arr.find(self)
		if self_index >-1:
			game_area.enemies_arr.remove_at(self_index)
		queue_free()
	else:
		if dir == Vector2i.LEFT:
			animated_sprite_2d.flip_h = true
		if dir == Vector2i.RIGHT:
			animated_sprite_2d.flip_h = false
		move(delta)

func move(dt:float) -> void: # move it
	if can_move:
		global_position = global_position.move_toward(game_area.tile_map_to_global(target_cell),SPEED*dt)
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")
	get_next_target(dt)
	
func get_next_target(_dt: float) -> void: # will return next target after reaching the target
	if global_position == game_area.tile_map_to_global(target_cell):
		current_cell = game_area.pos_to_tile_map(global_position)
		dir = get_new_dir()
		target_cell += dir
		

func get_new_dir() -> Vector2i:
	var available_neighbours 	: Array[Vector2i] = get_available_neighbours()
	var new_dirs 				: Array[Vector2i]
	if available_neighbours.size()>0:
		for i in range(0,available_neighbours.size()):
			if available_neighbours[i] != dir*-1:
				if current_cell+available_neighbours[i] not in game_area.bomb_cells_enemy:
					new_dirs.append(available_neighbours[i])
		if new_dirs.size()>0:
			var random_index : int = randi_range(0,new_dirs.size()-1)
			return new_dirs[random_index]
		else:
			return dir*-1
	else:
		return Vector2i.ZERO
	
func get_available_neighbours() -> Array[Vector2i]:
	var available_cells : Array[Vector2i]
	for i in dirs:
		if tile_map_layer.get_cell_source_id(current_cell+i) == FLOOR_SOURCE_ID:
			if !game_area.bomb_cells_enemy.has(current_cell+i):
				available_cells.append(i)
	return available_cells

func _on_body_entered(body: Node2D) -> void:
	body.die()
