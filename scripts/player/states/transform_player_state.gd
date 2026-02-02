extends PlayerState
class_name TransformPlayerState

signal transformed

func enter(player: Player):
	_prepare_transformation(player)
	_play_transformation_effects(player)
	await _perform_transformation()
	_complete_transformation(player)

func step(_player: Player, _delta: float):
	pass

func animate(player: Player, _delta: float):
	player.skin.set_animation_speed(1)
	player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.transform)

func exit(player: Player):
	_cleanup_transformation(player)
	transformed.emit()

func _prepare_transformation(player: Player):
	player.vulnerable = false
	player.shields.visible = false
	player.velocity = Vector2.ZERO
	player.rotation_degrees = 0

func _play_transformation_effects(player: Player):
	player.audios.transform_audio.play()
	player.skin.transitioning_pallete = true
	player.skin.pal_swapper.play("Transform")

func _perform_transformation():
	await get_tree().create_timer(0.9).timeout

func _complete_transformation(player: Player):
	player.set_super_state(true)
	player.is_rolling = false
	player.state_machine.change_state("Air")

func _cleanup_transformation(player: Player):
	player.skin.transitioning_pallete = false
	player.is_rolling = false
	player.is_jumping = false
