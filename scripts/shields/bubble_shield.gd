extends Shield

# Constants (guide values * 60 for per-second physics)
const DOWN_FORCE = 8 * 60  # 480 pixels/second
const BOUNCE_FORCE_AIR = 7.5 * 60  # 450 pixels/second
const BOUNCE_FORCE_UNDERWATER = 4.0 * 60  # 240 pixels/second
const MIN_AIRBORNE_TIME = 0.1  # Minimum time airborne before bubble drop can activate

# Node references
@onready var sprite = $Sprite2D
@onready var animation_player = $Sprite2D/AnimationPlayer
@export var action_audio_special: NodePath
@onready var special_audio = get_node(action_audio_special)

# State
var descending = false
var airborne_time = 0.0


func _ready():
	visible = false


func on_activate():
	visible = true
	set_attacking(false)
	shield_user.connect("ground_enter", Callable(self, "on_user_ground_enter"))
	animation_player.play("default")


func on_deactivate():
	descending = false
	airborne_time = 0.0
	visible = false
	animation_player.stop()


func _process(delta):
	if !shield_user:
		return
	
	if shield_user.super_state:
		return
	
	if get_parent().current_shield != get_parent().shields.BubbleShield:
		return
	
	# Track airborne time
	if !shield_user.__is_grounded:
		airborne_time += delta
	else:
		airborne_time = 0.0
	
	# Activate bubble bounce when pressing jump while airborne and rolling
	# AND has been airborne for minimum time (prevents activation on jump press)
	if (Input.is_action_just_pressed("player_a") and 
		!shield_user.__is_grounded and 
		shield_user.is_rolling and !shield_user.state_machine.current_state == "Transform" and
		airborne_time >= MIN_AIRBORNE_TIME):
		_activate_bubble_drop()


func _activate_bubble_drop():
	# Set X Speed to 0
	shield_user.velocity.x = 0
	
	# Set Y Speed to down_force
	shield_user.velocity.y = DOWN_FORCE
	
	descending = true
	set_attacking(true)


func set_attacking(value: bool):
	if value:
		animation_player.play("attack")
	else:
		animation_player.play("default")


func on_user_ground_enter():
	if get_parent().current_shield != get_parent().shields.BubbleShield:
		return
	
	if descending:
		_perform_bounce()


func _perform_bounce():
	if !shield_user.super_state:
		animation_player.play("bounce")
		special_audio.play()
		shield_user.state_machine.change_state("Air")
		shield_user.is_rolling = true
		
		# Calculate bounce using ground angle (convert to radians)
		var bounce = _get_bounce_force()
		var angle_rad = deg_to_rad(shield_user.ground_angle)
		
		shield_user.velocity.x -= bounce * sin(angle_rad)
		shield_user.velocity.y -= bounce * cos(angle_rad)
		
	descending = false


func _get_bounce_force() -> float:
	# Check if underwater (you'll need to implement this check based on your water system)
	var is_underwater = false  # Replace with actual underwater check
	return BOUNCE_FORCE_UNDERWATER if is_underwater else BOUNCE_FORCE_AIR


func _on_animation_finished(anim_name):
	if anim_name == "bounce":
		set_attacking(false)
