extends PlayerState

class_name DeadPlayerState

var typeof_death = ""

func enter(host: Player):
	host.shields.visible = false
	host.is_jumping = false
	host.is_rolling = false
	host.velocity.x = 0
	host.velocity.y = 0
	host.velocity.y -= 420
	host.colliding = false
	if typeof_death == "":
		host.audios.hurt.play()
	elif typeof_death == "spikes":
		host.audios.spike.play()

func step(host, delta):
	host.velocity.y += host.current_stats.gravity * delta
	host.velocity.x = 0

func animate(player: Player, _delta: float):
	if player.skin:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.dead)
