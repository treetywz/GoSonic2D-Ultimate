extends Node
class_name HUD

# Constants
const MAX_DISPLAYED_LIVES = 99
const SECONDS_PER_MINUTE = 60
const MS_MULTIPLIER = 100

# Label References
@onready var score_label = $Score/Score
@onready var rings_label = $Score/Rings
@onready var minutes_label = $Score/Timer/Minutes
@onready var seconds_label = $Score/Timer/Seconds
@onready var milliseconds_label = $Score/Timer/Milliseconds

# Lives UI (Desktop)
@onready var lifes = $Lives
@onready var lifes_label = $Lives/Counter
@onready var lifes_icon_handler = $Lives/NameHandler

# Lives UI (Mobile)
@onready var mob_lifes = $MobileLifes
@onready var lifes_mobile = $MobileLifes/Counter
@onready var mob_lifes_icon_handler = $MobileLifes/NameHandler

# Managers
@onready var score_manager = get_node("/root/ScoreManager") as ScoreManager

# Cached References
var player: Player
var _is_mobile: bool
var _last_player_id: String = ""
var _last_super_state: bool = false


func _ready():
	_is_mobile = _check_if_mobile()
	_setup_platform_ui()
	_connect_signals()
	_initialize_labels()


func _process(_delta):
	_update_player_reference()
	_update_timer()
	_update_player_icon()


func _check_if_mobile() -> bool:
	var os_name = OS.get_name()
	return os_name == "Android" or os_name == "iOS"


func _setup_platform_ui():
	lifes.visible = !_is_mobile
	mob_lifes.visible = _is_mobile


func _update_player_reference():
	var zone = get_node_or_null("/root/Zone")
	if zone:
		player = zone.player


func _update_timer():
	var time = score_manager.time
	var minutes = int(time / SECONDS_PER_MINUTE)
	var seconds = int(time) % SECONDS_PER_MINUTE
	var milliseconds = int(time * MS_MULTIPLIER) % MS_MULTIPLIER
	
	minutes_label.text = str(minutes)
	seconds_label.text = "%02d" % seconds
	milliseconds_label.text = "%02d" % milliseconds


func _update_player_icon():
	if !player:
		return
	
	# Only update if state changed (optimization)
	if player.player_id == _last_player_id and player.super_state == _last_super_state:
		return
	
	_last_player_id = player.player_id
	_last_super_state = player.super_state
	
	var animation_name = "Super Sonic" if (player.player_id == "Sonic" and player.super_state) else player.player_id
	
	lifes_icon_handler.play(animation_name)
	mob_lifes_icon_handler.play(animation_name)


func _connect_signals():
	score_manager.score_added.connect(_on_score_added)
	score_manager.ring_added.connect(_on_ring_added)
	score_manager.life_added.connect(_on_life_added)


func _initialize_labels():
	score_label.text = str(score_manager.score)
	rings_label.text = str(score_manager.rings)
	_update_lives_display(score_manager.lifes)


func _update_lives_display(_lifes: int):
	var display_value = (_lifes - MAX_DISPLAYED_LIVES) if _lifes > MAX_DISPLAYED_LIVES else _lifes
	lifes_label.text = str(display_value)
	lifes_mobile.text = str(display_value)


func _on_score_added(score: int):
	score_label.text = str(score)


func _on_ring_added(rings: int):
	rings_label.text = str(rings)


func _on_life_added(_lifes: int):
	_update_lives_display(_lifes)
