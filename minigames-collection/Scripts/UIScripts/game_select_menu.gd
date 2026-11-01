extends CanvasLayer
@onready var play_snake_button: Button = $SSSnakeContainer/VBoxContainer/PlaySnakeButton

func _ready() -> void:
	play_snake_button.grab_focus()
