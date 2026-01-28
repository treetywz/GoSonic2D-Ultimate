extends PlayerState

class_name VictoryPlayerState

func exit(_player: Player):
	pass

func enter(player: Player):
	player.set_bounds(0)
	player.is_rolling = false
	player.skin.set_animation_speed(1)
	player.velocity.x = 0
	player.velocity.y = 0
	player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.victory)
	
func step(player: Player, delta):
	player.handle_gravity(delta)
