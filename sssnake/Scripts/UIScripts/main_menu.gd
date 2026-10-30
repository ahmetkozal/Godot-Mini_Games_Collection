extends Control

@onready var play_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/EasyButton

func _ready() -> void:
	play_button.grab_focus()
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://UI/game_select_menu.tscn")
