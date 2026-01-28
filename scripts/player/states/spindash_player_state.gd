extends PlayerState

class_name SpinDashPlayerState


var p : float # spin dash release power

func enter(player: Player):
	player.is_looking_down = false
	player.dash_dust.visible = true
	player.audios.spindashcharge.play()
	p = 0
	player.is_rolling = true

func step(player: Player, _delta):
	player.is_looking_down = false
	if Input.is_action_just_released("player_down"):

		player.audios.spindashcharge.stop()
		var scaletemp = 0
		player.is_rolling = true
		if player.skin.flip_h == true:
			scaletemp = -1
		else:
			scaletemp = 1
		player.velocity.x = (480 + (floor(p) / 2)) * scaletemp
		player.audios.spindashrelease.play()
		player.delay_cam = true
		player.state_machine.change_state("Rolling")
	
	if (Input.is_action_just_pressed("player_a") or Input.is_action_just_pressed("player_b")):
		p += 120
		player.skin.get_node("AnimationPlayer").play("spindash")
		player.skin.get_node("AnimationPlayer").stop()
		#player.animation.stop(true)
		player.audios.spindashcharge.play()
		#player.audio_player.play('spin_dash_charge')
	
	p = min(p, 480)
	p -= int(p / 7.5) / 15360.0

func exit(player: Player):
	player.dash_dust.visible = false

func animate(player: Player, _delta: float):
	player.skin.set_animation_speed(1)
	player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.spindash)
