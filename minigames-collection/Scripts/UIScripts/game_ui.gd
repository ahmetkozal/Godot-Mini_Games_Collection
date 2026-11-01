extends CanvasLayer

@export var game_area: Node2D

@onready var left_panel: Control = $LeftPanel
@onready var right_panel: Control = $RightPanel

@onready var top_panel: Control = $TopPanel
@onready var bottom_panel: Control = $BottomPanel
@onready var score_and_move: VBoxContainer = $LeftPanel/PanelContainer/ScoreAndMove

var viewport_size: Vector2
var game_size: Vector2
var game_left: float
var game_right: float
var game_top: float
var game_bottom: float

#func _ready() -> void:
	#viewport_size = get_viewport().get_visible_rect().size
	#game_size = Vector2(game_area.grid_width, game_area.grid_height)
#
	#game_left = game_area.position.x
	#game_right = game_left + game_size.x
#
	#left_panel.position = Vector2.ZERO
	#left_panel.size = Vector2(game_left, viewport_size.y)
	#left_panel.self_modulate = Color.RED
	#right_panel.position = Vector2(game_right, 0)
	#right_panel.size = Vector2(viewport_size.x - game_right, viewport_size.y)
	#
	#print("Viewport: ", viewport_size)
	#print("GameArea: ", game_size)
	#print("GameLeft: ", game_left)
	#print("LeftPanel: ", left_panel.size)
	#
	##score_and_move.position = Vector2(10, 20)
