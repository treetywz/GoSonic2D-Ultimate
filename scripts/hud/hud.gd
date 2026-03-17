extends Control
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
@onready var lifes_icon = $Lives/Icon
@onready var lifes_name = $Lives/Name
@onready var lifes_label = $Lives/Counter

# Lives UI (Mobile)
@onready var mob_lifes = $MobileLifes
@onready var lifes_mobile = $MobileLifes/Counter
@onready var mob_lifes_icon = $MobileLifes/Icon
@onready var mob_lifes_name = $MobileLifes/Name

# Managers
@onready var score_manager = get_node("/root/ScoreManager") as ScoreManager

# Cached References
var player: Player
var _is_mobile: bool
var _last_player_id: String = ""
var _last_super_state: bool = false

var enabled = true

func _disable():
	enabled = false
	visible = false
	
func _enable():
	enabled = true
	visible = true
	_ready()

func _ready():
	if Global.find_zone_from_root():
		_is_mobile = _check_if_mobile()
		_setup_platform_ui()
		_connect_signals()
		_initialize_labels()


func _process(_delta):
	if enabled:
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
	var zone = Global.find_zone_from_root()
	if zone:
		player = zone.player

func _get_life_icon(id, supr):
	var to_load = str("res://sprites/hud/life_icons/", id, ".png")
	var to_load_super = str("res://sprites/hud/life_icons/Super", id, ".png")
	if ResourceLoader.exists(to_load_super) and supr:
		return load(to_load_super)
	elif !ResourceLoader.exists(to_load):
		push_warning("HUD: There was no file found at '%s'!" % to_load)
		return
	return load(to_load)
	
func _get_life_name_graphic(id):
	var to_load = str("res://sprites/hud/life_names/", id, ".png")
	if !ResourceLoader.exists(to_load):
		push_warning("HUD: There was no file found at '%s'!" % to_load)
		return
	return load(to_load)

func _update_timer():
	var time = score_manager.time
	var minutes = int(time / SECONDS_PER_MINUTE)
	var seconds = int(time) % SECONDS_PER_MINUTE
	var milliseconds = int(time * MS_MULTIPLIER) % MS_MULTIPLIER
	
	minutes_label.text = str(minutes)
	seconds_label.text = "%02d" % seconds
	milliseconds_label.text = "%02d" % milliseconds


func _check_color_update_redundancy():
	# As a side effect of this check, you HAVE to change replace_0 for it to even recognize
	# that you have switched palettes.
	
	var skin = player.skin
	var replace = skin.material.get_shader_parameter("replace_0")
	var compare = lifes_icon.material.get_shader_parameter("replace_2")
	
	if replace == compare:
		return false
	return true
		

func _update_color_palette():
	var skin = player.skin
	var to_replace = ["replace_2", "replace_1", "", "replace_0"]
	var to_original = ["original_2", "original_1", "", "original_0"]
	
	# Crappy workaround, but it works.
	# This is done because replace_0 on the player is replace_2 on the UI..
	# replace_1 is the same..
	# replace_2 on the player does not exist on the UI at all
	# replace_3 on the player is replace_0 on the UI...
	
	for i in range(0,4):
		if i == 2:
			continue
			
		var param = "replace_%s" % i
		var og_param = "original_%s" % i
		var replace = skin.material.get_shader_parameter(param)
		var original = skin.material.get_shader_parameter(og_param)
		
		lifes_icon.material.set_shader_parameter(to_original[i], original)
		mob_lifes_icon.material.set_shader_parameter(to_original[i], original)
		
		lifes_icon.material.set_shader_parameter(to_replace[i], replace)
		mob_lifes_icon.material.set_shader_parameter(to_replace[i], replace)

func _update_player_icon():
	if !player:
		return
		
	if _check_color_update_redundancy():
		_update_color_palette()
	
	if player.player_id == _last_player_id and player.super_state == _last_super_state:
		return
	
	_last_player_id = player.player_id
	_last_super_state = player.super_state
	
	var icon_graphic = _get_life_icon(player.player_id, player.super_state)
	var name_graphic = _get_life_name_graphic(player.player_id)
	
	lifes_icon.texture = icon_graphic
	lifes_name.texture = name_graphic
	mob_lifes_icon.texture = icon_graphic
	mob_lifes_name.texture = name_graphic


func _connect_signals():
	if not score_manager.score_added.is_connected(_on_score_added):
		score_manager.score_added.connect(_on_score_added)
	if not score_manager.ring_added.is_connected(_on_ring_added):
		score_manager.ring_added.connect(_on_ring_added)
	if not score_manager.life_added.is_connected(_on_life_added):
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
