extends Node2D
class_name Zone
# Zone Configuration
@export_group("Zone Info")
## The name of the zone, used for the title card.
@export var zone_name: String
## The amount of acts in the stage.
## This variable determines whether a sign post will load the next scene or continue the current one.
@export var amount_of_acts : int = 1
## The current act number.
@export var act_number: int
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
var global_ui: CanvasLayer
var hud: Control
var gameover: Control
var camera_resource = preload("res://objects/players/camera.tscn")
var death_handler_resource = preload("res://objects/players/death_handler.tscn")
var ui_resource: = preload("res://objects/hud/UI.tscn")

signal reset_signposts

@onready var zone_path = get_scene_file_path()

func _ready():
	_reset_score_manager()
	await _initialize_zone()

func _reset_score_manager():
	ScoreManager.reset_score(false, true, false)
	ScoreManager.time_stopped = false

func _reset_signposts():
	emit_signal("reset_signposts")

func _zone_music():
	MusicManager.play_music(zone_music)

# Main initialization sequence
func _initialize_zone():
	FadeManager.prefadeout()
	
	initialize_player()
	
	if snowboard_level:
		player.change_state("Snowboarding")
	
	initialize_camera()
	initialize_hud()
	initialize_death_handler()
	
	_zone_music()
	FadeManager.fade_out()
	
	await get_tree().create_timer(0.2).timeout
	_hide_loading_overlay()

func _hide_loading_overlay():
	var color_rect = global_ui.get_node_or_null("ColorRect")
	if color_rect:
		color_rect.visible = false

func get_current_act_limits() -> CameraLimits:
	var index = act_number - 1  # Convert to 0-based index
	if index >= 0 and index < acts.size():
		return acts[index]
	# Return default limits if act not configured
	var default_limits = CameraLimits.new()
	return default_limits

func initialize_player():
	var startPoint = str("StartPointAct", act_number)
	player = player_resource.instantiate()
	player.position = get_node_or_null(startPoint).position
	
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
