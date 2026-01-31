extends Node2D
class_name Signpost

# Properties
## The act that the sign post will be enabled in.
@export var act_number : int = 1
## Determines if the player keeps their rings after this sign post (provided there is an additional act afterwards).
## In the original games, the player's ring count is always reset to zero.
@export var keep_rings : bool = false

# Constants
const PLAYER_LOCK_OFFSET = 426
const POST_SPIN_DELAY = 2.0
const VICTORY_ANIM_DELAY = 0.6
const POST_TALLY_DELAY = 2.0
const FADE_DELAY = 1.0
const FADE_DURATION = 2.0
const MUSIC_FADE_DURATION = 3.0
const POLL_INTERVAL = 0.1

# Cached references
var player: Player
var camera: PlayerCamera

# State
var routined = false
var displayed = false
var acting = false

# Node references
@onready var zone : Zone = Global.find_zone_from_root()
@onready var anim_player = $AnimationPlayer
@onready var spin_audio = $Spin


func _ready():
	zone.reset_signposts.connect(_reset_signpost)
	_reset_signpost()

func _reset_signpost():
	acting = false
	await get_tree().create_timer(POLL_INTERVAL).timeout # Wait 0.1 seconds for player to be ready
	if act_number != Global.current_act:
		routined = true
		displayed = true
		_display_character_plate(player.player_id)
	else:
		routined = false
		displayed = false
		_display_character_plate("Eggman")
	acting = true

func _physics_process(_delta):
	if routined:
		return
	
	# Cache references if not set
	if !player:
		player = zone.player
	if !camera:
		camera = zone.camera
	
	if !player:
		return
	
	# Check if player reached the signpost
	if player.global_position.x >= global_position.x and acting:
		_trigger_signpost()


func _trigger_signpost():
	routined = true
	
	_spin_post()
	_setup_player_victory()
	
	await get_tree().create_timer(POST_SPIN_DELAY).timeout
	
	_display_character_plate(player.player_id)
	_start_music_transition()
	
	player.victory_anim()
	await get_tree().create_timer(VICTORY_ANIM_DELAY).timeout
	
	_enter_score_tally()
	
	await _wait_for_music_fade()
	await _play_victory_music()
	await _complete_score_tally()
	
	await get_tree().create_timer(POST_TALLY_DELAY).timeout
	
	_exit_and_transition()


func _spin_post():
	if anim_player.current_animation != "spin":
		anim_player.play("spin")
		spin_audio.play()


func _setup_player_victory():
	player.spun_sign_post = true
	player.skin.off_screen = true
	player.set_super_state(false)
	ScoreManager.stop_time()
	
	# Get the viewport width
	var viewport_width = get_viewport_rect().size.x
	
	# Position camera so limit_right is at the right edge of the screen
	# Camera position = limit_right - half screen width
	var new_limit_left = camera.limit_right - viewport_width
	camera.limit_left = int(new_limit_left)
	
	# Player can move across the entire visible screen
	player.lock_to_limits(int(new_limit_left), camera.limit_right)


func _display_character_plate(character: String):
	anim_player.play(character)
	displayed = true


func _start_music_transition():
	MusicManager.fade_out(MUSIC_FADE_DURATION)


func _enter_score_tally():
	UI.enter_tally(player.player_id, Global.current_act)


func _wait_for_music_fade():
	while MusicManager.fading:
		await get_tree().create_timer(POLL_INTERVAL).timeout


func _play_victory_music():
	MusicManager.reset_volume()
	MusicManager.play_music(zone.victory_music)
	
	while MusicManager.is_playing():
		await get_tree().create_timer(POLL_INTERVAL).timeout


func _complete_score_tally():
	UI.tally_total()
	
	while UI.is_tallying():
		await get_tree().create_timer(POLL_INTERVAL).timeout

func initialize_next_act(act_limits):
	if !keep_rings:
		ScoreManager.reset_score(false, false, true)
	player.change_state("Regular")
	zone._zone_music()
	zone._reset_signposts()
	player.lock_to_limits(player.limit_left, act_limits.limit_right)
	camera.tween_limits_from_resource(act_limits)
	ScoreManager.reset_time_and_start()
	_titlecard()

func _titlecard():
	UI.enter_titlecard(zone.zone_name)
	await get_tree().create_timer(2.7).timeout
	UI.exit_titlecard()

func _exit_and_transition():
	var go_next_scene = Global.current_act + 1 > zone.amount_of_acts

	UI.exit_tally()
	await get_tree().create_timer(FADE_DELAY).timeout
	
	# Safety check - don't transition if player died
	if player.state_machine.current_state == "Dead":
		return
	
	if go_next_scene:
		Global.current_act = 1
		UI.fade_in()
		await get_tree().create_timer(FADE_DURATION).timeout
		GoData.save_file()
		LoadingScreen.load_scene(Global.find_zone_from_root(), zone.next_scene)
	else:
		Global.current_act += 1
		var act_limits = zone.get_current_act_limits()
		initialize_next_act(act_limits)
