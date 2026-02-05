extends Node2D
class_name Zone

@export_group("Zone Info")
## The name of the zone, used for the title card.
@export var zone_name: String
## The amount of acts in the stage.
## This variable determines whether a sign post will load the next scene or continue the current one.
@export var amount_of_acts: int = 1
## The file path to the next scene to be loaded after a zone's final act.
## It defaults to the project's main scene.
@export var next_scene: String = ProjectSettings.get_setting("application/run/main_scene")
## Determines if the built-in zone intro (fade out, title card, enabling player inputs, playing the zone music) is skipped.
## This is useful if you want to manually script how the zone starts, hence the name.
@export var scripted_intro: bool = false

@export_group("Resources")
## The player object the zone will load upon initializing.
@export var player_resource: PackedScene

@export_group("Audio")
## The audio stream the zone plays upon initializing.
@export var zone_music: AudioStream
## The audio stream played after the sign post spins.
@export var victory_music: AudioStream = load("res://audios/musics/act-clear.wav")

@export_group("Level Settings")
## Determines the player's starting state.
@export_enum(
	"Regular",
	"Rolling",
	"Braking",
	"Air",
	"Spring",
	"SpinDash",
	"SuperPeelOut",
	"DropDash",
	"Dead",
	"Hurt",
	"Transform",
	"Victory",
	"Snowboarding",
) var starting_player_state : String = "Regular"

@export_group("Camera Limits")
## Camera limits for each act. Index 0 = Act 1, Index 1 = Act 2, etc.
@export var acts: Array[CameraLimits] = [CameraLimits.new()]
## Editor only; determines what act's boundaries is displayed.
@export_range(1, 9223372036854775807) var show_act: int = 1


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

# Signals
signal reset_signposts

# Onready
@onready var zone_path = get_scene_file_path()

# Cutscene Variables
var cutscenes := {}

func _ready():
	_check_for_errors()
	MusicManager.fading = false
	ScoreManager.time_stopped = true
	ScoreManager.reset_score(false, true, false)
	await _initialize_zone()

func _check_for_errors():
	# Critical errors (will crash)
	assert(player_resource != null, "Zone: No player resource set!")
	assert(FileAccess.file_exists(next_scene), "Zone: Next scene '%s' does not exist!" % next_scene)

	# Warnings (non-critical)
	if !zone_music:
		push_warning("Zone '%s': There is no zone music set!" % get_scene_file_path())
	if !victory_music:
		push_warning("Zone '%s': There is no victory music set!" % get_scene_file_path())
	if zone_name.is_empty():
		push_warning("Zone '%s': There is no zone name set!" % get_scene_file_path())

func _reset_signposts():
	emit_signal("reset_signposts")

func _zone_music():
	MusicManager.play_music(zone_music)

# Main initialization sequence
func _initialize_zone():
	UI.black_screen()
	
	_initialize_player()
	
	player.change_state(starting_player_state)
	
	_initialize_camera()
	_initialize_death_handler()
	
	if !scripted_intro or ScoreManager.has_died:
		_initialize_zone_intros()
	else:
		custom_intro()
	
func _initialize_zone_intros():
	_zone_music()
	await _initialize_titlecard()
	await pause(0.2)

func _initialize_titlecard():
	UI.enter_titlecard(zone_name)
	await pause(1.3)
	UI.fade_out()
	await pause(0.4)
	
	player.can_move = true
	player.gravity_affected = true
	player.vulnerable = true
	ScoreManager.time_stopped = false
	
	await pause(1.2)
	UI.exit_titlecard()

func _initialize_player():
	var start_point_name = "StartPointAct" + str(Global.current_act)
	var start_point = get_node_or_null(start_point_name)
	
	assert(start_point != null, "There is no start point for Act %d!" % Global.current_act)
	
	player = player_resource.instantiate()
	player.position = start_point.position
	player.can_move = false
	player.vulnerable = false
	player.gravity_affected = false
	
	lock_player_limits()
	
	add_child(player)


func _initialize_camera():
	camera = camera_resource.instantiate()
	camera.set_player(player)
	
	var limits = get_current_act_limits()
	camera.set_limits(limits.limit_left, limits.limit_right, limits.limit_top, limits.limit_bottom)
	
	add_child(camera)

func _initialize_death_handler():
	death_handler = death_handler_resource.instantiate()
	death_handler.zone_to_reload = zone_path
	add_child(death_handler)

# Helper functions

func get_current_act_limits() -> CameraLimits:
	var index = Global.current_act - 1
	if index >= 0 and index < acts.size():
		return acts[index]
	return CameraLimits.new()

func pause(seconds: float):
	await get_tree().create_timer(seconds).timeout
	
func lock_player_limits():
	var limits = get_current_act_limits()
	player.lock_to_limits(limits.limit_left, limits.limit_right)
	
func set_player_limit_left(limit : int):
	player.lock_to_limits(limit, player.limit_right)
	
func set_player_limit_right(limit : int):
	player.lock_to_limits(player.limit_left, limit)
	
func set_player_global_x(x : float):
	player.global_position.x = x
	
func set_player_global_y(y : float):
	player.global_position.y = y
	
func play_cutscene(id: int) -> void:
	if cutscenes.has(id):
		await cutscenes[id].call()
	else:
		assert(false, "Cutscene %d is not a valid cutscene!" % id)

# This function should be declared by the inheriting node if a custom intro is used.
func custom_intro():
	pass
