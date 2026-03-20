extends Area2D

@onready var player = get_parent() as Player

func _on_hanging_area_detected(area: Area2D) -> void:
	if area.get_parent() is FlyingPlayerState:
		var ai = area.get_parent().get_parent().get_parent() as Player
		if (
			ai.state_machine.current_state == "Flying" and
			!Input.is_action_pressed("player_down") and
			!player.__is_grounded and
			player.hanging_object == null and
			player.velocity.y > 0
		):
			player.hanging_object = ai
			player.audios.grab.play()
			player.change_state("Hanging")
