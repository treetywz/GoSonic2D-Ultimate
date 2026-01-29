extends PlayerState

class_name TransformPlayerState

func exit(player: Player):
	player.skin.transitioning_pallete = false
	player.is_rolling = false
	player.is_jumping = false

func enter(player: Player):
	player.vulnerable = false
	player.shields.visible = false
	player.audios.transform_audio.play()
	player.skin.transitioning_pallete = true
	player.skin.pal_swapper.play("Transform3D")
	player.velocity.x = 0
	player.velocity.y = 0
	player.rotation_degrees = 0
	await get_tree().create_timer(0.9).timeout
	player.set_super_state(true)
	player.is_rolling = false
	player.state_machine.change_state("Air")
	
func animate(player: Player, _delta):
	player.skin.set_animation_speed(1)
	player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.transform)
	
func step(_player: Player, _delta):
	pass
