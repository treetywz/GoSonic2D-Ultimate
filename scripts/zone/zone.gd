
extends Node2D
class_name Zone

# Zone Configuration
@export_group("Zone Info")
@export var zone_name: String
@export var act_number: int
@export var zone_path: String
@export var next_scene: String

# Scene Resources
@export_group("Resources")
@export var player_resource: PackedScene
@export var camera_resource: PackedScene
@export var death_handler_resource: PackedScene
@export var zone_hud: PackedScene

# Audio
@export_group("Audio")
@export var zone_music: AudioStream
@export var victory_music: AudioStream

# Level Settings
@export_group("Level Settings")
@export var snowboard_level: bool = false

# Camera Limits
@export_group("Camera Limits")
@export var limit_left: int = 0
@export var limit_right: int = 10000
@export var limit_top: int = 0
@export var limit_bottom: int = 10000

# Node References
@onready var start_point = $StartPoint

# Runtime Variables
var player: Player
var camera: PlayerCamera
var death_handler: DeathChecker
var global_zone_hud: CanvasLayer
var hud: Control
var gameover: Control


func _ready():
	_reset_score_manager()
	await _initialize_zone()


func _reset_score_manager():
	ScoreManager.reset_score(false, true, false)
	ScoreManager.time_stopped_goal = false


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
	var color_rect = global_zone_hud.get_node_or_null("ColorRect")
	if color_rect:
		color_rect.visible = false


func initialize_player():
	player = player_resource.instantiate()
	player.position = start_point.position
	player.lock_to_limits(limit_left, limit_right)
	add_child(player)


func initialize_camera():
	camera = camera_resource.instantiate()
	camera.set_player(player)
	camera.set_limits(limit_left, limit_right, limit_top, limit_bottom)
	add_child(camera)


func initialize_death_handler():
	death_handler = death_handler_resource.instantiate()
	death_handler.zone_to_reload = zone_path
	add_child(death_handler)


func initialize_hud():
	global_zone_hud = zone_hud.instantiate()
	add_child(global_zone_hud)
	hud = global_zone_hud.get_node("HUD")
	gameover = global_zone_hud.get_node("GameOver")
