extends Control

@onready var game = $GAME
@onready var over = $OVER

func _ready():
	game.visible = false
	over.visible = false

func over_anim(type):
	game.visible = true
	over.visible = true
	if type == "game":
		print("AD")
		$AnimationPlayer.play("gameover")
	else:
		$AnimationPlayer.play("timeover")
