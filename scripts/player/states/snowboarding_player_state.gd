extends PlayerState
class_name SnowboardingPlayerState

const GROUND_SPEED := 850.0
const AIR_SPEED := 600.0
const JUMP_FORCE := 180.0

func enter(player: Player):
	player.set_bounds(0)

func step(player: Player, delta: float):
	player.handle_gravity(delta)
	
	if player.gravity_affected:
		_handle_movement(player)
		_handle_jump(player)

func animate(player: Player, _delta: float):
	if player.__is_grounded:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.snowboard)
	else:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.snowboard_jump)

func exit(_player: Player):
	pass

# Private helper functions
func _handle_movement(player: Player):
	var speed := GROUND_SPEED if player.__is_grounded else AIR_SPEED
	player.velocity.x = speed * _get_direction(player)

func _handle_jump(player: Player):
	if Input.is_action_just_pressed("player_a") and player.__is_grounded:
		player.audios.jump_audio.play()
		player.velocity.y = -JUMP_FORCE

func _get_direction(player: Player) -> float:
	return -1.0 if player.skin.flip_h else 1.0
