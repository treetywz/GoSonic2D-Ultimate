extends Node2D
class_name Signpost

# Properties
@export var act_number: int = 1
@export var keep_rings: bool = false

# Constants
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

# Node references
@onready var zone: Zone = Global.find_zone_from_root()
@onready var anim_player = $AnimationPlayer
@onready var spin_audio = $Spin

func _ready():
	zone.reset_signposts.connect(_reset_signpost)
	_reset_signpost()

func _reset_signpost():
	await get_tree().create_timer(POLL_INTERVAL).timeout
	
	if act_number != Global.current_act:
		routined = true
		_display_character_plate(player.player_id)
	else:
		routined = false
		_display_character_plate("Eggman")

func _physics_process(_delta):
	if routined:
		return
	
	if !player:
		player = zone.player
	if !camera:
		camera = zone.camera
	
	if !player:
		return
	
	if player.global_position.x >= global_position.x:
		_trigger_signpost()

func _trigger_signpost():
	routined = true
	player.vulnerable = false
	
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
	
	var viewport_width = get_viewport_rect().size.x
	var new_limit_left = camera.limit_right - viewport_width
	
	camera.limit_left = int(new_limit_left)
	player.lock_to_limits(int(new_limit_left), camera.limit_right)

func _display_character_plate(character: String):
	anim_player.play(character)

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

func _initialize_next_act(act_limits: CameraLimits):
	if !keep_rings:
		ScoreManager.reset_score(false, false, true)
	
	player.spun_sign_post = false
	player.change_state("Regular")
	player.lock_to_limits(player.limit_left, act_limits.limit_right)
	
	zone._zone_music()
	zone._reset_signposts()
	
	camera.tween_limits_from_resource(act_limits)
	
	ScoreManager.reset_time_and_start()
	
	await _show_titlecard()

func _show_titlecard():
	UI.enter_titlecard(zone.zone_name)
	await get_tree().create_timer(2.9).timeout
	UI.exit_titlecard()

func _exit_and_transition():
	var is_final_act = Global.current_act + 1 > zone.amount_of_acts
	
	UI.exit_tally()
	await get_tree().create_timer(FADE_DELAY).timeout
	
	if player.state_machine.current_state == "Dead":
		return
	
	if is_final_act:
		Global.current_act = 1
		UI.fade_in()
		await get_tree().create_timer(FADE_DURATION).timeout
		GoData.save_file()
		LoadingScreen.load_scene(Global.find_zone_from_root(), zone.next_scene)
	else:
		Global.current_act += 1
		var act_limits = zone.get_current_act_limits()
		await _initialize_next_act(act_limits)
