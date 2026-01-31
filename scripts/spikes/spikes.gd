extends Node2D
class_name SpikeObject

const HURT_CHECK_INTERVAL = 0.01

var is_hurting_player = false

func _on_solid_object_player_ground_collision(player: Player):
	if is_hurting_player:
		return
	
	# Immediately push player up slightly to prevent visual clipping
	if player.vulnerable and player.velocity.y > 0:
		player.position.y -= 13
	
	is_hurting_player = true
	_handle_ground_collision(player)
	is_hurting_player = false

func _handle_ground_collision(player: Player):
	# Immediate hurt check
	if player.vulnerable and _should_hurt_player(player):
		player.hurt("spikes", self)
		return
	
	# Wait if player is currently invulnerable
	while !player.vulnerable:
		if !player.__is_grounded:
			return
		await get_tree().create_timer(HURT_CHECK_INTERVAL).timeout
	
	# Check again after becoming vulnerable
	if _should_hurt_player(player):
		player.hurt("spikes", self)

func _should_hurt_player(player: Player) -> bool:
	if !player.ground_colliding_object or !player.vulnerable:
		return false
	
	var still_touching = player.ground_colliding_object.get_parent() == self
	var bubble_descending = player.shields.shields.BubbleShield.descending
	
	return still_touching or bubble_descending
