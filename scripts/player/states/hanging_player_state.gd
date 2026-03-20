extends PlayerState
class_name HangingPlayerState

func enter(player: Player):
	player.is_rolling = false
	player.gravity_affected = false
	player.velocity = Vector2.ZERO

func exit(player: Player):
	player.gravity_affected = true
	if player.hanging_object is Player:
		player.velocity.x = player.hanging_object.velocity.x
	if player.get_parent() != player.initial_parent:
		player.call_deferred("reparent", player.initial_parent)
	player.hanging_object = null
	player.skin.offset = Vector2.ZERO

func step(player: Player, _delta: float):
	if !player.hanging_object:
		player.change_state("Regular")
		return
	if player.hanging_object is Player:
		var ai = player.hanging_object
		player.velocity = Vector2.ZERO

		if player.get_parent() != ai:
			player.call_deferred("reparent", ai)
		else:
			player.position = Vector2(0.0, 38.0)
		
		if is_colliding_with_ground(player, ai) or is_colliding_with_wall(player, ai):
			player.change_state("Air")
			return
			
		if Input.is_action_just_pressed("player_a") and Input.is_action_pressed("player_down"):
			player.is_rolling = true
			player.is_jumping = true
			player.audios.jump_audio.play()
			player.velocity.y -= player.current_stats.max_jump_height
			player.change_state("Air")

func is_colliding_with_ground(player, ai):
	var ray_offset = player.transform.x * player.current_bounds.width_radius
	var ray_size = player.current_bounds.height_radius
	var exclude = [player, ai]
	var hits = GoPhysics.cast_parallel_rays(
		player.get_world_2d(),
		player.global_position,
		ray_offset,
		player.transform.y,
		ray_size,
		exclude,
		player.ground_layer
	)
	return hits

func is_colliding_with_wall(player, ai):
	var wall_size = player.current_bounds.width_radius + player.current_bounds.push_radius
	var exclude = [player, ai]
	var right_ray = GoPhysics.cast_ray(
		player.get_world_2d(),
		player.global_position,
		player.transform.x,
		wall_size,
		exclude,
		player.wall_layer
	)
	var left_ray = GoPhysics.cast_ray(
		player.get_world_2d(),
		player.global_position,
		-player.transform.x,
		wall_size,
		exclude,
		player.wall_layer
	)
	return right_ray or left_ray

func animate(player: Player, _delta: float):
	player.skin.set_animation_speed(1.0)
	player.skin.set_animation_state("hanging")
	if player.hanging_object is Player:
		player.skin.flip_h = player.hanging_object.skin.flip_h
		player.skin.offset.x = 5.0 if !player.skin.flip_h else -5.0
	else:
		player.skin.handle_flip(player.input_direction.x)
