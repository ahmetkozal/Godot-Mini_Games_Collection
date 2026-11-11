extends Powerup

enum Powerups {
	MAX_BOMBS,
	FIRE_RANGE,
	MAX_RANGE,
	SKATE
}

@export var powerup_ = Powerups.MAX_BOMBS


func apply_powerup(bomber : PlayerBomber):
	match powerup_:
		Powerups.MAX_BOMBS:
			bomber.max_bombs += 1
		Powerups.FIRE_RANGE:
			bomber.explosion_range += 1
		Powerups.MAX_RANGE:
			bomber.explosion_range = 10
		Powerups.SKATE:
			bomber.speed *= 1.1

func get_animation_name() -> String:
	match powerup_:
		Powerups.MAX_BOMBS:
			return "max_bombs_anim"
		Powerups.FIRE_RANGE:
			return "fire_range_anim"
		Powerups.MAX_RANGE:
			return "max_fire_range_anim"
		Powerups.SKATE:
			return "skate_anim"
	return ""
