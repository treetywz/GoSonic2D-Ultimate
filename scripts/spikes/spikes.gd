extends Node2D

# State
var is_hurting_player = false
@export var track = false
var tracking = false

# Constants
const HURT_CHECK_INTERVAL = 0.1

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("player_c") and track:
		tracking = true
	if tracking:
		print(global_position.distance_to(get_parent().get_parent().player.global_position))

func _on_solid_object_player_ground_collision(player: Player):
	# Only hurt if player is touching from above (grounded on spikes)
	_attempt_hurt_player(player)


func _attempt_hurt_player(player: Player):
	if player.state_machine.current_state != "Hurt":
		is_hurting_player = true
		
		print("HURT")
		
		while !player.vulnerable:
			if !player.__is_grounded:
				return
			await get_tree().create_timer(HURT_CHECK_INTERVAL).timeout
		
		# Check if player is still on the spikes
		if is_hurting_player:
			if (player.__is_grounded or player.shields.shields.BubbleShield.descending) and global_position.distance_to(player.global_position) < 40:
				player.hurt("spikes", self)
		
		is_hurting_player = false
