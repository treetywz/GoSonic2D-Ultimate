extends PlayerState
class_name SuperPeeloutPlayerState

@export var DASH_SPEED: float = 720
@export var CHARGE_TIME: float = 1

var charge_timer : float
var animation_speed : float
var scaletemp = 1

func enter(player: Player):
	charge_timer = CHARGE_TIME
	animation_speed = 1.0
	player.audios.peeloutcharge.play()
	player.velocity = Vector2.ZERO

func step(player: Player, delta):
	player.is_looking_up = false
	charge_timer -= delta
	animation_speed += (720.0 / pow(CHARGE_TIME, 2.0)) * delta
	animation_speed = min(animation_speed, 720.0)
	
	var up_released: bool
	
	if player.artificial_input_enabled:
		# For artificial input - check if up was released (transition from true to false)
		up_released = !player.artificial_look_up
	else:
		# For normal input
		up_released = Input.is_action_just_released("player_up")
	
	if up_released:
		if charge_timer <= 0:
			if player.skin.flip_h == true:
				scaletemp = -1
			else:
				scaletemp = 1
			player.velocity.x = DASH_SPEED * scaletemp
			player.delay_cam = true
			player.audios.peeloutrelease.play()
		else:
			player.audios.peeloutcharge.stop()
			pass
		player.state_machine.change_state("Regular")

func exit(_player: Player):
	pass

func animate(player: Player, _animator):
	var anim_speed = max(-(8.0 / 60.0 - (animation_speed / 120.0)), 1.0)
	player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.walking)
	if animation_speed >= 360:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.running)
		
	if animation_speed >= 720:
		player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.peel_out)
		
	player.skin.set_animation_speed(anim_speed)
