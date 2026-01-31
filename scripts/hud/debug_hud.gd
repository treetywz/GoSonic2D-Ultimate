extends Control

class_name DebugHUD

@onready var fps = $Labels/FPS
@onready var x_pos = $Labels/XPOS
@onready var y_pos = $Labels/YPOS
@onready var x_sp = $Labels/XSP
@onready var y_sp = $Labels/YSP
@onready var cstate = $Labels/CSTATE
@onready var lstate = $Labels/LSTATE
@onready var lookup = $Labels/LOOKUP
@onready var crouch = $Labels/CROUCH
@onready var isrolling = $Labels/ISROLLING
@onready var isgrounded = $Labels/ISGROUNDED
@onready var ispushing = $Labels/ISPUSHING
@onready var animstate = $Labels/ANIMSTATE
@onready var groundangle = $Labels/GROUNDANGLE
@onready var lifesadded = $Labels/LIFESADDED
@onready var vulnerabletext = $Labels/VULNERABLE
@onready var spiked = $Labels/SPIKED

@onready var zone : Zone

const FORMAT = "%.2f"


var enabled = true
var s  = false

func _disable():
	enabled = false
	visible = false
	
func _enable():
	enabled = true
	visible = true
	_ready()

func _ready() -> void:
	zone = Global.find_zone_from_root()
	


func _process(_delta):
	if Input.is_action_just_pressed("ui_debug") and enabled:
		if $Labels.visible == true:
			$Labels.visible = false
		elif $Labels.visible == false:
			$Labels.visible = true
			
	if zone != null:

		var player_position = zone.player.position
		var player_velocity = zone.player.velocity
		var statemachine = zone.player.state_machine
		var vulnerable = zone.player.vulnerable
		
		x_pos.text = FORMAT % player_position.x
		y_pos.text = FORMAT % player_position.y
		x_sp.text = FORMAT % player_velocity.x
		y_sp.text = FORMAT % player_velocity.y
		cstate.text = statemachine.current_state
		lstate.text = statemachine.last_state
		lookup.text = str(zone.player.is_looking_up)
		crouch.text = str(zone.player.is_looking_down)
		isrolling.text = str(zone.player.is_rolling)
		isgrounded.text = str(zone.player.__is_grounded)
		ispushing.text = str(zone.player.is_pushing)
		groundangle.text = str(abs(zone.player.ground_angle))
		lifesadded.text = str(ScoreManager.lifes_added)
		fps.text = str(Engine.get_frames_per_second())
		vulnerabletext.text = str(vulnerable)
		spiked.text = str(zone.player.has_been_spiked)
		
		
		if cstate.text == "SuperPeelOut":
			cstate.text = "PeelOut"
		if lstate.text == "SuperPeelOut":
			lstate.text = "PeelOut"
