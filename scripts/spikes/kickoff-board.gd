extends Area2D



func _on_area_entered(area):
	if area.get_parent() is Player:
		var player = area.get_parent()
		if player.state_machine.current_state == "Snowboarding":
			player.kick_off_board(self)
