extends Node2D

class_name Shield

@export var invincible: bool = true
@export var ring_protection: bool = true

@export var activation_audio_path: NodePath
@export var action_audio_path: NodePath

@onready var activate_audio = get_node_or_null(activation_audio_path)
@onready var action_audio = get_node_or_null(action_audio_path)

var active: bool
var shield_user

func activate(player):
	if not active:
		if activate_audio:
			activate_audio.play()
	
		active = true
		shield_user = player
		on_activate()

func deactivate():
	if active:
		active = false
		on_deactivate()

func action():
	if active:
		if action_audio and !shield_user.super_state:
			action_audio.play()
		
		on_action()

func on_activate():
	pass

func on_deactivate():
	pass

func on_action():
	pass
