extends PlayerState
class_name SpinDashPlayerState

var p : float # spin dash release power

func enter(player: Player):
	player.is_looking_down = false
	player.dash_dust.visible = true
	player.audios.spindashcharge.play()
	player.velocity = Vector2.ZERO
	p = 0
	player.is_rolling = true

func step(player: Player, _delta):
	player.is_looking_down = false
	
	var down_released: bool
	var jump_pressed: bool
	
	if player.artificial_input_enabled:
		# For artificial input
		# Check if down was released (transition from true to false)
		down_released = !player.artificial_look_down
		jump_pressed = player.artificial_jump
	else:
		# For normal input
		down_released = Input.is_action_just_released("player_down")
		jump_pressed = Input.is_action_just_pressed("player_a") or Input.is_action_just_pressed("player_b")
	
	# Release spin dash
	if down_released:
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
	
	# Charge spin dash
	if jump_pressed:
		p += 120
		player.skin.get_node("AnimationPlayer").play("spindash")
		player.skin.get_node("AnimationPlayer").stop()
		player.audios.spindashcharge.play()
	
	p = min(p, 480)
	p -= int(p / 7.5) / 15360.0

func exit(player: Player):
	player.dash_dust.visible = false

func animate(player: Player, _delta: float):
	player.skin.set_animation_speed(1)
	player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.spindash)
