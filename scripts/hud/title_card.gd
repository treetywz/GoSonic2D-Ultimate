extends Control

@onready var anim = $AnimationPlayer
@onready var zname = $Container/ZoneName
@onready var _act = $Container/Act

var act_images = ["res://sprites/scoretally/act1.png", "res://sprites/scoretally/act2.png"]

func enter_title_card(zone_name):
	var act_index = Global.current_act - 1
	anim.play("enter")
	zname.text = str(zone_name).to_upper()
	if act_images[act_index]:
		_act.texture = load(act_images[act_index])
	else:
		_act.texture = load(act_images[0])
	
func exit_title_card():
	anim.play("exit")
