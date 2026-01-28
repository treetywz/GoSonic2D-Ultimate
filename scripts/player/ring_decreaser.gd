extends Node2D

@onready var player = get_parent()

func _process(_delta):
	if player.super_state:
		if $decrease_rings.is_stopped():
			$decrease_rings.start()
			ScoreManager.remove_ring(1)

func _on_timeout():
	$decrease_rings.stop()
