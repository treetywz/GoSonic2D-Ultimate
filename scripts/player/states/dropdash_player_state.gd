extends PlayerState
class_name DropDashPlayerState

const DROPDASH_DUST = preload("res://objects/particles/DropDashDust.tscn")
const DUST_OFFSET_LEFT = -17

func enter(_player: Player):
	pass

func step(player: Player, _delta):
	var stats = player.current_stats
	var drpspd = stats.drpspd
	var drpmax = stats.drpmax
	
	var dir = _get_direction(player)
	var is_moving_backward = _is_moving_backward(player, dir)
	var ground_speed = player.velocity.x  # Current ground speed
	
	# Calculate new ground speed based on movement direction
	if is_moving_backward:
		# Moving backwards (opposite to facing direction)
		if player.ground_angle == 0:
			# Flat ground: set speed to drpspd
			player.velocity.x = drpspd * dir
		else:
			# On slopes: divide by 2 instead of 4
			player.velocity.x = (ground_speed / 2.0) + (drpspd * dir)
	else:
		# Moving forwards
		player.velocity.x = (ground_speed / 4.0) + (drpspd * dir)
	
	# Clamp to max speed
	player.velocity.x = clampf(player.velocity.x, -drpmax, drpmax)
	
	_play_audio_and_effects(player, dir)
	player.state_machine.change_state("Rolling")

func exit(player: Player):
	player.audios.dropdash.stop()

# Check if player is moving opposite to facing direction
func _is_moving_backward(player: Player, facing_dir: int) -> bool:
	return (player.velocity.x < 0 and facing_dir == 1) or (player.velocity.x > 0 and facing_dir == -1)

# Get the direction the player is facing (-1 left, 1 right)
func _get_direction(player: Player) -> int:
	return -1 if player.skin.flip_h else 1

func _play_audio_and_effects(player: Player, dir: int):
	player.audios.spindashrelease.play()
	player.delay_cam = true
	
	var dust = DROPDASH_DUST.instantiate()
	dust.global_position = player.skin.get_node("DropDustSpawn").global_position
	dust.scale.x = dir
	
	if dir == -1:
		dust.offset.x = DUST_OFFSET_LEFT
	
	player.get_parent().add_child(dust)
