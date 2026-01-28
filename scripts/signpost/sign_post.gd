extends Node2D
class_name Signpost

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
var zone: Zone

# State
var routined = false
var displayed = false

# Node references
@onready var anim_player = $AnimationPlayer
@onready var spin_audio = $Spin


func _ready():
	zone = get_parent()


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
	if player.global_position.x >= global_position.x:
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
	ScoreManager.stop_time_goal()
	
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
	ScoreTally.enter(player.player_id, zone.act_number)


func _wait_for_music_fade():
	while MusicManager.fading:
		await get_tree().create_timer(POLL_INTERVAL).timeout


func _play_victory_music():
	MusicManager.reset_volume()
	MusicManager.play_music(zone.victory_music)
	
	while MusicManager.is_playing():
		await get_tree().create_timer(POLL_INTERVAL).timeout


func _complete_score_tally():
	ScoreTally.tally_total()
	
	while ScoreTally.is_tallying():
		await get_tree().create_timer(POLL_INTERVAL).timeout


func _exit_and_transition():
	ScoreTally.exit()
	await get_tree().create_timer(FADE_DELAY).timeout
	
	# Safety check - don't transition if player died
	if player.state_machine.current_state == "Dead":
		return
	
	FadeManager.fade_in()
	await get_tree().create_timer(FADE_DURATION).timeout
	
	go_data.save_file()
	global_load.load_scene(get_tree().root.get_node("Zone"), zone.next_scene)
