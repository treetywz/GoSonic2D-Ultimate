extends Control

@onready var game = $GAME
@onready var over = $OVER
@onready var anim = $AnimationPlayer

func _disable():
	visible = false
	
func _enable():
	visible = true
	_ready()

func _ready():
	game.visible = false
	over.visible = false

func over_anim(type):
	game.visible = true
	over.visible = true
	anim.play(str(type,"over"))
