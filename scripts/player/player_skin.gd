extends Sprite2D

class_name PlayerSkin

@onready var animation_tree = $AnimationTree
@onready var player = get_parent()
@onready var pal_swapper = $PaletteSwapper
var transitioning_palette = false
var off_screen = false
var current_state : String

func _ready():
	animation_tree.active = true

func _process(_delta):
	if is_instance_valid(player):
		player.dash_dust.flip_h = flip_h
		if player.dash_dust.flip_h == true:
			player.dash_dust.offset.x = 32
		else:
			player.dash_dust.offset.x = 0

func handle_flip(direction: float) -> void:
	if is_instance_valid(player):
		if !player.is_looking_down:
			if !player.is_looking_up:
				if direction != 0:
					flip_h = direction < 0
					player.dash_dust.flip_h = direction < 0
					if player.dash_dust.flip_h == true:
						player.dash_dust.offset.x = 32
					else:
						player.dash_dust.offset.x = 0
		if !player.is_looking_up:
			if !player.is_looking_down:
				if direction != 0:
					flip_h = direction < 0

func set_animation_state(state_name: String) -> void:
	if state_name != current_state:
		current_state = state_name
		var playback = animation_tree.get("parameters/playback")
		if not playback:
			playback = animation_tree.get("parameters/StateMachine/playback")
		if playback:
			if _state_exists(state_name):
				playback.travel(state_name)
			else:
				push_warning("PlayerSkin: state '%s' not found in AnimationTree, defaulting to hurt" % state_name)
				playback.travel("hurt")
	else:
		animation_tree.set("parameters/StateMachine/transition_request", state_name)

func _state_exists(state_name: String) -> bool:
	var blend_tree = animation_tree.tree_root
	if blend_tree is AnimationNodeBlendTree:
		var sm = blend_tree.get_node("StateMachine")
		if sm is AnimationNodeStateMachine:
			return sm.has_node(state_name)
	return false

func set_running_animation_state(speed: float) -> void:
	var state = "walking"

	if speed > 355 and speed <= 595:
		state = "running"
	elif speed > 595:
		state = "peel_out"

	set_animation_state(state)

func set_animation_speed(value: float) -> void:
	animation_tree.set("parameters/speed/scale", value)

func set_regular_animation_speed(value: float) -> void:
	var speed = max(8.0 / 60.0 + value / 120.0, 1.0)
	set_animation_speed(speed)

func set_rolling_animation_speed(value: float) -> void:
	var speed = max(4 / 60.0 + value / 120.0, 1.0)
	set_animation_speed(speed)

func set_palette(value : String):
	if value == "super":
		if pal_swapper.current_animation != "SuperPalette":
			pal_swapper.play("SuperPalette")
	elif value == "normal":
		if pal_swapper.current_animation != "NormalPalette":
			pal_swapper.play("NormalPalette")

func _on_exit_screen() -> void:
	var zone = Global.find_zone_from_root()
	off_screen = true
	if is_instance_valid(player) and is_instance_valid(zone):
		if player.state_machine.current_state == "Dead":
			visible = false
		elif player.global_position.y > zone.camera.limit_bottom:
			player.change_state("Dead")

func _on_enter_screen() -> void:
	off_screen = false

func _on_palette_swap_finished(anim_name) -> void:
	if anim_name == "Detransform":
		transitioning_palette = false
