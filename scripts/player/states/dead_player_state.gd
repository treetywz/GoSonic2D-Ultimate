extends PlayerState
class_name DeadPlayerState

var death_type := ""

func enter(player: Player):
	ScoreManager.has_died = true
	_reset_player_state(player)
	_apply_death_physics(player)
	_play_death_sound(player)

func step(player: Player, delta: float):
	player.velocity.y += player.current_stats.gravity * delta
	player.velocity.x = 0

func animate(player: Player, _delta: float):
	if player.skin:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.dead)

func _reset_player_state(player: Player):
	player.shields.visible = false
	player.is_jumping = false
	player.is_rolling = false
	player.colliding = false

func _apply_death_physics(player: Player):
	player.velocity = Vector2.ZERO
	player.velocity.y = -420

func _play_death_sound(player: Player):
	match death_type:
		"spikes":
			player.audios.spike.play()
		_:
			player.audios.hurt.play()
