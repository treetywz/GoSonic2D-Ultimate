extends PlayerState
class_name HurtPlayerState

func enter(player: Player):
	_disable_player_abilities(player)

func step(player: Player, _delta: float):
	player.velocity.y += player.current_stats.hurt_gravity_force

func animate(player: Player, _delta: float):
	player.skin.set_animation_state(PlayerSkin.ANIMATION_STATES.hurt)

func exit(player: Player):
	player.iframes()

func launch(player: Player, hazard: Node2D):
	var direction := _get_knockback_direction(player, hazard)
	player.velocity.x = player.current_stats.hurt_x_force * direction
	player.velocity.y = player.current_stats.hurt_y_force

func _disable_player_abilities(player: Player):
	player.can_collect_rings = false
	player.vulnerable = false
	player.is_rolling = false

func _get_knockback_direction(player: Player, hazard: Node2D) -> float:
	var direction: float = sign(player.global_position.x - hazard.global_position.x)
	return direction if direction != 0 else 1.0

func _on_ground_enter() -> void:
	var player := get_parent().get_parent() as Player
	if player.state_machine.current_state == "Hurt":
		player.state_machine.change_state("Regular")
