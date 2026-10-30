extends Control

@onready var play_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/EasyButton

func _ready() -> void:
	play_button.grab_focus()
