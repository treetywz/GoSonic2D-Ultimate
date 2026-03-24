extends PlayerState

class_name FlyingPlayerState

const gravityDefault = 112.5
const airAccel = 337.5
const airDecel = 137.5
const yVelocityGravCap = -56.25

var gravity = 112.5
var can_propel = true

@onready var stamina = $Stamina

func enter(player: Player):
	stamina.start()
	can_propel = true
	player.is_rolling = false
	player.is_jumping = false

func exit(player: Player):
	stamina.stop()
	player.audios.flying_audio.stop()
	player.audios.tired_flying_audio.stop()

func step(player: Player, delta: float):
	handle_air_acceleration(player, delta)
	handle_gravity(player, delta)
	handle_flying_audio(player)
	handle_flight_cancel(player)
	
	if player.__is_grounded:
		player.change_state("Regular")

func animate(player: Player, _delta: float):
	player.skin.handle_flip(player.input_direction.x)
	player.skin.set_animation_speed(1.0)
	
	if can_propel and player.being_hanged_onto and player.velocity.y < 0:
		player.skin.set_animation_state("flying_carry_pull")
	elif can_propel and player.being_hanged_onto:
		player.skin.set_animation_state("flying_carry")
	elif can_propel and !player.being_hanged_onto:
		player.skin.set_animation_state("flying")
	elif player.being_hanged_onto:
		player.skin.set_animation_state("flying_carry_tired")
	else:
		player.skin.set_animation_state("flying_tired")

func handle_flying_audio(player):
	if can_propel and !player.audios.flying_audio.playing:
		player.audios.tired_flying_audio.stop()
		player.audios.flying_audio.play()
	elif !can_propel and !player.audios.tired_flying_audio.playing:
		player.audios.flying_audio.stop()
		player.audios.tired_flying_audio.play()

func handle_gravity(player : Player, delta):
	player.velocity.y += gravity * delta
	if player.velocity.y < yVelocityGravCap or player.ceiling_colliding_object:
		# When the player reaches a certain y velocity (or touches the ceiling), stop cheating the
		# laws of physics and make gravity go back to normal.
		gravity = gravityDefault
	if Input.is_action_just_pressed("player_a") and can_propel:
		# Yes, it changes the gravity rather than simply applying force to the player.
		# This is the same logic that's actually used in the original Genesis games.
		gravity = -450

func handle_flight_cancel(player):
	if (Input.is_action_just_pressed("player_a") and 
		Input.is_action_pressed("player_down") and
		!player.cpu_input_enabled):

		player.is_rolling = true
		player.change_state("Air")

func handle_air_acceleration(player, delta):
	if sign(player.input_direction.x) == sign(player.velocity.x) or !player.__is_grounded:
		if abs(player.velocity.x) < player.current_stats.top_speed:
			player.velocity.x += player.input_direction.x * airAccel * delta
			player.velocity.x = clamp(player.velocity.x, -player.current_stats.top_speed, player.current_stats.top_speed)
	else:
		player.velocity.x += player.input_direction.x * player.current_stats.deceleration * delta
	player.velocity.x = move_toward(player.velocity.x, 0, airDecel * delta)


func _on_stamina_depleted() -> void:
	can_propel = false
