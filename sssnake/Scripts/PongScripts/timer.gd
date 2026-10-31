extends Timer

@onready var timer_label: Label = $"../../PongGameUI/TimerLabel"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var seconds = fmod(ceili(time_left), 60)
	timer_label.text = "%2d" % seconds
	if seconds <= 0:
		timer_label.hide()
