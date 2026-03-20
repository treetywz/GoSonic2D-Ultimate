extends PlayerState

class_name FlyingPlayerState

const gravityDefault = 112.5
const airAccel = 337.5
const airDecel = 137.5

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
	
	if can_propel and !player.audios.flying_audio.playing:
		player.audios.tired_flying_audio.stop()
		player.audios.flying_audio.play()
	elif !can_propel and !player.audios.tired_flying_audio.playing:
		player.audios.flying_audio.stop()
		player.audios.tired_flying_audio.play()
		
	if (Input.is_action_just_pressed("player_a") and 
		Input.is_action_pressed("player_down") and
		!player.artificial_input_enabled):
		player.is_rolling = true
		player.change_state("Air")
	
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

func handle_gravity(player : Player, delta):
	player.velocity.y += gravity * delta
	if player.velocity.y < -56.25 or player.ceiling_colliding_object:
		gravity = gravityDefault
	if Input.is_action_just_pressed("player_a") and can_propel:
		gravity = -450

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
