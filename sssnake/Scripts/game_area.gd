extends Node2D

@export var grid_width: int = 160
@export var grid_height: int = 160
@onready var time_label_min: Label = $"../GameUI/RightPanel/PanelContainer/VBoxContainer/HBoxContainer/TimeLabelMin"
@onready var time_label_sec: Label = $"../GameUI/RightPanel/PanelContainer/VBoxContainer/HBoxContainer/TimeLabelSec"
@onready var time_label_mini_sec: Label = $"../GameUI/RightPanel/PanelContainer/VBoxContainer/HBoxContainer/TimeLabelMiniSec"
@onready var snake: CharacterBody2D = $Snake


var time_passed : float
var minutes 	: int
var seconds		: int
var mini_sec	: int
func _ready() -> void:
	position = (get_viewport_rect().size - Vector2(grid_width, grid_height)) / 2
	print("Viewport: ", get_viewport_rect().size)
	print("GameArea position: ", position)

func _physics_process(delta: float) -> void:
	if !snake.dead:
		time_passed += delta
	minutes = fmod(time_passed,3600) / 60
	seconds = fmod(time_passed, 60)
	mini_sec = fmod(time_passed, 1) * 100
	
	time_label_min.text 		= "%02d:" % minutes
	time_label_sec.text 		= "%02d:" % seconds
	time_label_mini_sec.text 	= "%02d" % mini_sec
