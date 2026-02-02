extends PlayerState
class_name AirPlayerState

# State
var last_absolute_horizontal_speed: float
var last_absolute_vertical_speed: float
var can_use_shield: bool
var drop_dash: bool = false
var can_drop_dash: bool = true

# Cached references
@onready var audio_player = get_parent().get_parent().get_node("Audios")
@onready var drop_dash_timer = $DropDashTimer

func enter(player: Player):
	can_use_shield = player.is_rolling
	last_absolute_horizontal_speed = abs(player.velocity.x)
	last_absolute_vertical_speed = abs(player.velocity.y)
	
	if player.is_rolling:
		player.set_bounds(1)

func step(player: Player, delta: float):
	player.handle_gravity(delta)
	player.handle_jump()
	player.handle_acceleration(delta)
	
	if player.is_grounded():
		_handle_landing(player)
	else:
		_handle_airborne_input(player)

func _handle_landing(player: Player):
	drop_dash_timer.stop()
	
	if drop_dash:
		drop_dash = false
		player.state_machine.change_state("DropDash")
	elif player.input_direction.y < 0:
		player.state_machine.change_state("Rolling")
	else:
		player.state_machine.change_state("Regular")

func _handle_airborne_input(player: Player):
	var b_pressed: bool
	
	if player.artificial_input_enabled:
		# For artificial input, check the artificial_jump flag
		b_pressed = player.artificial_jump
	else:
		b_pressed = Input.is_action_just_pressed("player_b")
	
	# Transform input
	if b_pressed and player.can_transform:
		player.state_machine.change_state("Transform")
		return
	
	# Shield ability input
	if _check_shield_input(player) and can_use_shield:
		can_use_shield = false
		player.shields.use_current()
	
	# Drop dash input
	_handle_drop_dash_input(player)

func _check_shield_input(player: Player) -> bool:
	if player.artificial_input_enabled:
		return player.artificial_jump
	else:
		return Input.is_action_just_pressed("player_a") or Input.is_action_just_pressed("player_b")

func _handle_drop_dash_input(player: Player):
	var a_pressed: bool
	var b_pressed: bool
	var a_released: bool
	var b_released: bool
	
	if player.artificial_input_enabled:
		# For artificial input
		a_pressed = player.artificial_jump
		b_pressed = player.artificial_jump
		a_released = player.artificial_jump_release
		b_released = player.artificial_jump_release
	else:
		# For normal input
		a_pressed = Input.is_action_just_pressed("player_a")
		b_pressed = Input.is_action_just_pressed("player_b")
		a_released = Input.is_action_just_released("player_a")
		b_released = Input.is_action_just_released("player_b")
	
	# Start drop dash charge
	if player.is_jumping:
		if a_pressed and _can_use_drop_dash(player) and can_drop_dash:
			drop_dash_timer.start()
		elif b_pressed and !player.can_transform and _can_use_drop_dash(player) and can_drop_dash:
			drop_dash_timer.start()
	
	# Cancel drop dash charge
	if a_released or b_released:
		drop_dash_timer.stop()
		can_drop_dash = true
		drop_dash = false

func _can_use_drop_dash(player: Player) -> bool:
	if player.super_state:
		return true
	
	var shield = player.shields.current_shield
	return (shield == player.shields.shields.InstaShield or 
			shield == player.shields.shields.BlueShield)

func exit(_player: Player):
	drop_dash_timer.stop()
	can_drop_dash = true
	drop_dash = false

func animate(player: Player, _delta: float):
	player.skin.handle_flip(player.input_direction.x)
	var max_speed = max(last_absolute_horizontal_speed, last_absolute_vertical_speed)
	
	if drop_dash:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.dropdash)
	elif player.state_machine.last_state == "Transform":
		player.skin.set_running_animation_state(last_absolute_horizontal_speed)
	elif player.is_rolling:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.rolling)
		if !player.is_jumping:
			player.skin.set_rolling_animation_speed(max_speed)
	elif player.state_machine.last_state == "Regular":
		player.skin.set_running_animation_state(max_speed)
		player.skin.set_regular_animation_speed(max_speed)
	else:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.walking)

func dropdash_timer_timeout():
	if !drop_dash:
		audio_player.dropdash.play()
		drop_dash = true
		can_drop_dash = false
