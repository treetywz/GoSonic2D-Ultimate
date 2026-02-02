extends PlayerState
class_name RegularPlayerState

func enter(player: Player):
	player.set_bounds(0)

func step(player: Player, delta: float):
	_reset_state_flags(player)
	
	if player.__is_grounded:
		_handle_grounded_input(player, delta)
	else:
		player.state_machine.change_state("Air")

func _reset_state_flags(player: Player):
	player.is_looking_down = false
	player.is_looking_up = false
	player.is_pushing = false


func _handle_grounded_input(player: Player, delta: float):
	var stats = player.current_stats
	var abs_velocity_x = abs(player.velocity.x)
	
	# Check for special moves first
	if _try_special_moves(player, abs_velocity_x):
		return
	
	# Handle normal movement
	player.handle_jump()
	player.handle_fall()
	player.handle_gravity(delta)
	player.handle_slope(delta)
	player.handle_acceleration(delta)
	player.handle_friction(delta)
	
	# Update pushing state
	_update_pushing_state(player)
	
	# Check for state transitions
	if player.input_dot_velocity < 0 and abs_velocity_x >= stats.min_speed_to_brake:
		player.state_machine.change_state("Braking")
	elif player.input_direction.y < 0:
		if abs_velocity_x > stats.min_speed_to_roll:
			player.state_machine.change_state("Rolling")
		else:
			player.velocity.x = 0
			player.is_looking_down = true
	elif player.input_direction.y > 0 and abs_velocity_x < stats.min_speed_to_roll:
		player.velocity.x = 0
		player.is_looking_up = true


func _try_special_moves(player: Player, abs_velocity_x: float) -> bool:
	var jump_pressed: bool
	var down_pressed: bool
	var up_pressed: bool
	
	if player.artificial_input_enabled:
		# For artificial input, we need to track if jump was just triggered
		# Since artificial_do_jump() is a one-frame trigger, we read it here
		jump_pressed = player.artificial_jump
		down_pressed = player.artificial_look_down
		up_pressed = player.artificial_look_up
	else:
		jump_pressed = Input.is_action_just_pressed("player_a") or Input.is_action_just_pressed("player_b")
		down_pressed = Input.is_action_pressed("player_down")
		up_pressed = Input.is_action_pressed("player_up")
	
	if !jump_pressed or player.is_pushing or !player.can_move:
		return false
	
	# Spin Dash
	if down_pressed:
		player.state_machine.change_state("SpinDash")
		return true
	
	# Super Peel Out
	if up_pressed and abs_velocity_x < player.current_stats.min_speed_to_roll:
		player.state_machine.change_state("SuperPeelOut")
		return true
	
	return false


func _update_pushing_state(player: Player):
	if player.input_direction.x > 0 and player.right_push.is_colliding():
		player.is_pushing = true
	elif player.input_direction.x < 0 and player.left_push.is_colliding():
		player.is_pushing = true
	else:
		player.is_pushing = false


func animate(player: Player, _delta: float):
	var abs_speed = abs(player.velocity.x)
	
	player.skin.handle_flip(player.input_direction.x)
	player.skin.set_regular_animation_speed(abs_speed)
	
	if abs_speed >= 0.3:
		player.skin.set_running_animation_state(abs_speed)
	elif player.is_pushing:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.pushing)
	elif player.is_looking_up:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.lookup)
	elif player.is_looking_down:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.crouch)
	elif abs_speed == 0:
		_handle_ledge_balancing(player)
	else:
		_set_idle_animation(player)


func _handle_ledge_balancing(player: Player):
	# Only check ledge balance on flat ground
	if abs(player.ground_angle) > 3:
		_set_idle_animation(player)
		return
	
	var left_hit = player.ledge_left.is_colliding()
	var right_hit = player.ledge_right.is_colliding()
	var middle_hit = player.ledge_mid.is_colliding()
	var middle_left_hit = player.ledge_mid_left.is_colliding()
	var middle_right_hit = player.ledge_mid_right.is_colliding()
	
	# Both feet on ground or no ledge detected
	if left_hit == right_hit and middle_hit:
		_set_idle_animation(player)
		return
	
	# Right foot off ledge (left foot on ground)
	if left_hit and !right_hit:
		if !middle_hit:
			_set_balance_animation(player, "panic", false)
		elif !middle_right_hit:
			_set_balance_animation(player, "balance", false)
		else:
			_set_idle_animation(player)
	# Left foot off ledge (right foot on ground)
	elif !left_hit and right_hit:
		if !middle_hit:
			_set_balance_animation(player, "panic", true)
		elif !middle_left_hit:
			_set_balance_animation(player, "balance", true)
		else:
			_set_idle_animation(player)
	else:
		_set_idle_animation(player)


func _set_idle_animation(player: Player):
	if player.super_state:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.idle_super)
	else:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.idle)


func _set_balance_animation(player: Player, type: String, flip_left: bool):
	player.skin.flip_h = flip_left
	
	if player.super_state:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.balancing_super)
	elif type == "panic":
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.panic_balance)
	else:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.balance)


func exit(player: Player):
	player.is_pushing = false
	player.is_looking_down = false
	player.is_looking_up = false
