extends Node2D
class_name Zone

# Zone Configuration
@export_group("Zone Info")
## The name of the zone, used for the title card.
@export var zone_name: String
## The amount of acts in the stage.
## This variable determines whether a sign post will load the next scene or continue the current one.
@export var amount_of_acts: int = 1
## The file path to the next scene to be loaded after a zone's final act.
@export var next_scene: String = "res://scenes/title.tcsn"

# Scene Resources
@export_group("Resources")
## The player object the zone will load upon initializing.
@export var player_resource: PackedScene

# Audio
@export_group("Audio")
## The audio stream the zone plays upon initializing.
@export var zone_music: AudioStream
## The audio stream played after the sign post spins.
@export var victory_music: AudioStream

# Level Settings
@export_group("Level Settings")
## Determines whether or not the player spawns in the Snowboarding state.
@export var snowboard_level: bool = false

# Camera Limits
@export_group("Camera Limits")
## Camera limits for each act. Index 0 = Act 1, Index 1 = Act 2, etc.
@export var acts: Array[CameraLimits] = [CameraLimits.new()]

# Runtime Variables
var player: Player
var camera: PlayerCamera
var death_handler: DeathChecker
var global_ui = UI
var hud: Control
var gameover: Control

# Preloaded Resources
var camera_resource = preload("res://objects/players/camera.tscn")
var death_handler_resource = preload("res://objects/players/death_handler.tscn")
var ui_resource := preload("res://objects/hud/UI.tscn")

# Signals
signal reset_signposts

@onready var zone_path = get_scene_file_path()

func _ready():
	MusicManager.fading = false
	ScoreManager.reset_score(false, true, false)
	await _initialize_zone()

func _reset_signposts():
	emit_signal("reset_signposts")

func _zone_music():
	MusicManager.play_music(zone_music)

# Main initialization sequence
func _initialize_zone():
	UI.black_screen()
	
	initialize_player()
	
	if snowboard_level:
		player.change_state("Snowboarding")
	
	initialize_camera()
	initialize_death_handler()
	
	_zone_music()
	await _initialize_titlecard()
	
	await get_tree().create_timer(0.2).timeout
	_hide_loading_overlay()

func _initialize_titlecard():
	UI.enter_titlecard(zone_name)
	await get_tree().create_timer(1.3).timeout
	UI.fade_out()
	await get_tree().create_timer(0.4).timeout
	
	player.can_move = true
	player.gravity_affected = true
	player.vulnerable = true
	ScoreManager.time_stopped = false
	
	await get_tree().create_timer(1.2).timeout
	UI.exit_titlecard()

func _hide_loading_overlay():
	var color_rect = global_ui.get_node_or_null("ColorRect")
	if color_rect:
		color_rect.visible = false

func get_current_act_limits() -> CameraLimits:
	var index = Global.current_act - 1
	if index >= 0 and index < acts.size():
		return acts[index]
	return CameraLimits.new()

func initialize_player():
	var start_point_name = "StartPointAct" + str(Global.current_act)
	var start_point = get_node_or_null(start_point_name)
	
	player = player_resource.instantiate()
	player.position = start_point.position
	player.can_move = false
	player.vulnerable = false
	player.gravity_affected = false
	
	var limits = get_current_act_limits()
	player.lock_to_limits(limits.limit_left, limits.limit_right)
	
	add_child(player)

func initialize_camera():
	camera = camera_resource.instantiate()
	camera.set_player(player)
	
	var limits = get_current_act_limits()
	camera.set_limits(limits.limit_left, limits.limit_right, limits.limit_top, limits.limit_bottom)
	
	add_child(camera)

func initialize_death_handler():
	death_handler = death_handler_resource.instantiate()
	death_handler.zone_to_reload = zone_path
	add_child(death_handler)

func initialize_hud():
	global_ui = ui_resource.instantiate()
	add_child(global_ui)
	hud = global_ui.get_node("HUD")
	gameover = global_ui.get_node("GameOver")
