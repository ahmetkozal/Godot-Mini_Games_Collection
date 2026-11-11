class_name Powerup
extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.play(get_animation_name())
	
func _on_body_entered(body: Node2D) -> void:
	apply_powerup(body)
	queue_free()

func apply_powerup(bomber : PlayerBomber):
	pass

func get_animation_name() -> String:
	return ""
