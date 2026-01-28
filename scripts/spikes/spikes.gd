extends Node2D

# State
var is_hurting_player = false

# Constants
const HURT_CHECK_INTERVAL = 0.1


func _on_solid_object_player_ground_collision(player: Player):
	# Only hurt if player is touching from above (grounded on spikes)
	_attempt_hurt_player(player)


func _attempt_hurt_player(player: Player):
	if player.state_machine.current_state != "Hurt":
		is_hurting_player = true
		
		while !player.vulnerable:
			if !player.__is_grounded:
				return
			await get_tree().create_timer(HURT_CHECK_INTERVAL).timeout
		
		# Wait for spike immunity to end
		while player.has_been_spiked:
			if !player.__is_grounded:
				return
			await get_tree().create_timer(HURT_CHECK_INTERVAL).timeout
		
		# Check if player is still on the spikes
		if player.__is_grounded and is_hurting_player:
			player.hurt("spikes", self)
		
		is_hurting_player = false
