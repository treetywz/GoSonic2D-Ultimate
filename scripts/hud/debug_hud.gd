extends Node

class_name DebugHUD

@export var zone_path: NodePath

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

@onready var zone = get_node(zone_path)

var score_manager = ScoreManager

const FORMAT = "%.2f"

const ANIMATION_STATES = {
	0: "idle",
	1: "walking",
	2: "running",
	3: "peel_out",
	4: "rolling",
	5: "skidding",
	6: "corkscrew",
	7: "crouch",
	8: "spindash",
	9: "lookup",
	10: "dropdash",
	11: "balance",
	12: "panic_balance",
	13: "idle_wait",
	14: "pushing",
	15: "dead",
	16: "hurt",
	17: "hurt_2",
	18: "idle_super",
	19: "balancing_super",
	20: "transform"
}

func _process(_delta):
	if Input.is_action_just_pressed("ui_debug"):
		if $Labels.visible == true:
			$Labels.visible = false
		elif $Labels.visible == false:
			$Labels.visible = true

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
	animstate.text = str(convertIntToString(zone.player.skin.current_state))
	groundangle.text = str(abs(zone.player.ground_angle))
	lifesadded.text = str(score_manager.lifes_added)
	fps.text = str(Engine.get_frames_per_second())
	vulnerabletext.text = str(vulnerable)
	
	
	if cstate.text == "SuperPeelOut":
		cstate.text = "PeelOut"
	if lstate.text == "SuperPeelOut":
		lstate.text = "PeelOut"

func convertIntToString(state_id: int) -> String:
	if state_id in ANIMATION_STATES:
		return ANIMATION_STATES[state_id]
	else:
		return "Unknown State"
