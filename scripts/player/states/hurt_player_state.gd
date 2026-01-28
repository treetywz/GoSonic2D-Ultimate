extends PlayerState

class_name HurtPlayerState

var launched = false

func exit(_player: Player):
	_player.iframes()
	launched = false
	pass

func enter(player: Player):
	player.can_collect_rings = false
	player.vulnerable = false
	player.is_rolling = false
	
func animate(player: Player, _delta):
	player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.hurt)
	
func step(player: Player, _delta):
	player.velocity.y += player.current_stats.hurt_gravity_force

func launch(player, hazard):
	var a = sign(player.global_position.x - hazard.global_position.x)
	
	if a == 0:
		a = 1
	
	player.velocity.y = player.current_stats.hurt_y_force
	player.velocity.x = player.current_stats.hurt_x_force * a


func _on_Sonic_ground_enter():
	var player = get_parent().get_parent()
	if player.state_machine.current_state == "Hurt":
		player.state_machine.change_state("Regular")
