extends PlayerState

class_name SnowboardingPlayerState

func exit(_player: Player):
	pass

func enter(player: Player):
	player.set_bounds(0)
	
func animate(player: Player, _delta):
	if player.__is_grounded:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.snowboard)
	else:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.snowboard_jump)
	
func step(player: Player, delta):
	player.handle_gravity(delta)
	if player.gravity_affected:
		if player.__is_grounded:
			player.velocity.x = 850 * direction(player)
		else:
			player.velocity.x = 600 * direction(player)
		if Input.is_action_just_pressed("player_a") and player.__is_grounded:
			player.audios.jump_audio.play()
			player.velocity.y -= 180

func direction(player):
	if player.skin.flip_h == true:
		return -1
	else:
		return 1
