extends PlayerState
class_name VictoryPlayerState

func enter(player: Player):
	_setup_victory_state(player)
	_reset_physics(player)
	_play_victory_animation(player)

func step(player: Player, delta: float):
	player.handle_gravity(delta)

func exit(player: Player):
	player.vulnerable = true

func _setup_victory_state(player: Player):
	player.set_bounds(0)
	player.is_rolling = false

func _reset_physics(player: Player):
	player.velocity = Vector2.ZERO

func _play_victory_animation(player: Player):
	player.skin.set_animation_speed(1)
	player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.victory)
