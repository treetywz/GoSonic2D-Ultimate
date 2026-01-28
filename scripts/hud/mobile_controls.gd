extends Control

# Constants
const FADE_SPEED = 0.05  # Per frame at 60fps (0.05 * 60 = 3.0/sec)
const FADE_INTERVAL = 0.016  # ~60fps
const ALPHA_MIN = 0.0
const ALPHA_MAX = 1.0

# Node References
@onready var dpad_anim = $Dpad/AnimationPlayer
@onready var b_button = $Buttons/B

# State
var is_fading_b_button = false
var is_fading_hud = false

# Cached references
var _player: Player
var _zone: Node


func _ready():
	_setup_visibility()
	_cache_references()


func _process(_delta):
	if !_player:
		return
	
	_update_b_button_visibility()
	_handle_b_button_fade()
	_handle_hud_fade()
	_update_dpad_animation()


# Initialize visibility based on platform
func _setup_visibility():
	var is_mobile = OS.get_name() in ["Android", "iOS"]
	var _is_debug = OS.is_debug_build()
	visible = is_mobile


# Cache player and zone references
func _cache_references():
	_zone = get_parent().get_parent()
	if _zone:
		_player = _zone.player


# Update B button visibility based on alpha
func _update_b_button_visibility():
	b_button.visible = b_button.self_modulate.a > ALPHA_MIN


# Handle B button fade logic
func _handle_b_button_fade():
	var should_show_b = _should_show_b_button()
	var current_alpha = b_button.self_modulate.a
	
	if should_show_b and current_alpha < ALPHA_MAX and !is_fading_b_button:
		_fade_b_button(true)
	elif !should_show_b and current_alpha > ALPHA_MIN and !is_fading_b_button:
		if _player.state_machine.current_state != "Transform3D":
			_fade_b_button(false)


# Check if B button should be shown
func _should_show_b_button() -> bool:
	return (_player.can_transform and 
			_player.state_machine.current_state == "Air")


# Handle HUD fade on victory
func _handle_hud_fade():
	if modulate.a == ALPHA_MAX and !is_fading_hud:
		if _player.state_machine.current_state == "Victory":
			_fade_hud(false)


# Update D-pad animation based on input
func _update_dpad_animation():
	var animation = "neutral"
	
	if Input.is_action_pressed("player_right"):
		animation = "right"
	elif Input.is_action_pressed("player_left"):
		animation = "left"
	elif Input.is_action_pressed("player_up"):
		animation = "up"
	elif Input.is_action_pressed("player_down"):
		animation = "down"
	
	dpad_anim.play(animation)


# Fade B button in or out
func _fade_b_button(fade_in: bool):
	is_fading_b_button = true
	var target_alpha = ALPHA_MAX if fade_in else ALPHA_MIN
	
	while is_fading_b_button:
		var delta_alpha = FADE_SPEED if fade_in else -FADE_SPEED
		b_button.self_modulate.a = clampf(
			b_button.self_modulate.a + delta_alpha,
			ALPHA_MIN,
			ALPHA_MAX
		)
		
		if b_button.self_modulate.a == target_alpha:
			is_fading_b_button = false
			break
		
		await get_tree().create_timer(FADE_INTERVAL).timeout


# Fade entire HUD in or out
func _fade_hud(fade_in: bool):
	is_fading_hud = true
	var target_alpha = ALPHA_MAX if fade_in else ALPHA_MIN
	
	while is_fading_hud:
		var delta_alpha = FADE_SPEED if fade_in else -FADE_SPEED
		modulate.a = clampf(
			modulate.a + delta_alpha,
			ALPHA_MIN,
			ALPHA_MAX
		)
		
		if modulate.a == target_alpha:
			is_fading_hud = false
			break
		
		await get_tree().create_timer(FADE_INTERVAL).timeout
