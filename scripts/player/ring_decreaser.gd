extends Node2D

@onready var player = get_parent()
@onready var timer = $decrease_rings

func _process(_delta):
	if player.super_state:
		if timer.is_stopped():
			timer.start()
			ScoreManager.remove_ring(1)

func _on_timeout():
	timer.stop()
