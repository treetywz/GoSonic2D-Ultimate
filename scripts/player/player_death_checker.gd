extends Node2D
class_name DeathChecker

# Constants
const FADE_DURATION = 2.0
const DEATH_DELAY = 1.0
const OFFSCREEN_CHECK_INTERVAL = 0.1
const GAME_OVER_SCENE = "res://scenes/title.tscn"
const DEFAULT_LIVES = 3

# Exports
@export var game_over: AudioStream

# State
var zone_to_reload: String
var routined = false
var can_skip = false
var can_time_skip = false

# Cached References
var player: Player
var hud: Control
var gameover: Control
var life_counter: Label
var mobile_life_counter: Label


func _ready():
	_cache_references()
	routined = false


func _process(_delta):
	if player.state_machine.current_state == "Dead":
		_handle_death()
	
	if can_skip and _skip_input_pressed():
		_execute_game_over_skip()
	elif can_time_skip and _skip_input_pressed():
		_execute_time_over_skip()


func _cache_references():
	var zone = get_parent()
	player = zone.player
	gameover = zone.gameover
	hud = zone.hud
	life_counter = hud.get_node("Lives/Counter")
	mobile_life_counter = hud.get_node("MobileLifes/Counter")


func _skip_input_pressed() -> bool:
	return Input.is_action_just_pressed("player_a") or Input.is_action_just_pressed("ui_accept")


func _execute_game_over_skip():
	can_skip = false
	MusicManager.fade_out(FADE_DURATION)
	skip_gameover()


func _execute_time_over_skip():
	can_time_skip = false
	MusicManager.fade_out(FADE_DURATION)
	skip()


func _handle_death():
	if routined:
		return
	
	routined = true
	player.process_mode = PROCESS_MODE_ALWAYS
	player.skin.z_index = 60
	get_tree().paused = true
	
	ScoreManager.lifes -= 1
	ScoreManager.time_stopped = true
	
	# Wait for player to go off screen
	await _wait_for_player_offscreen()
	await get_tree().create_timer(DEATH_DELAY).timeout
	# Determine death type and handle accordingly
	var death_type = _get_death_type()
	_update_life_counters()
	await _handle_death_type(death_type)
	


func _wait_for_player_offscreen():
	var fail_safe = 0
	while !player.skin.off_screen:
		fail_safe += 0.1
		if fail_safe > 3:
			break
		await get_tree().create_timer(OFFSCREEN_CHECK_INTERVAL).timeout


func _update_life_counters():
	var lives_text = str(ScoreManager.lifes)
	life_counter.text = lives_text
	mobile_life_counter.text = lives_text


enum DeathType { NORMAL_RETRY, TIME_OVER, GAME_OVER }

func _get_death_type() -> DeathType:
	var has_lives = ScoreManager.lifes > 0
	var time_limit_reached = round(ScoreManager.time) == ScoreManager.TIME_LIMIT
	
	if has_lives and !time_limit_reached:
		return DeathType.NORMAL_RETRY
	elif has_lives and time_limit_reached:
		return DeathType.TIME_OVER
	else:
		return DeathType.GAME_OVER


func _handle_death_type(death_type: DeathType):
	match death_type:
		DeathType.NORMAL_RETRY:
			MusicManager.fade_out(FADE_DURATION)
			skip()
		
		DeathType.TIME_OVER:
			can_time_skip = true
			_play_game_over_screen("time")
			await get_tree().create_timer(game_over.get_length()).timeout
			MusicManager.fade_out(FADE_DURATION)
			skip()
		
		DeathType.GAME_OVER:
			can_skip = true
			_play_game_over_screen("game")
			await get_tree().create_timer(game_over.get_length()).timeout
			MusicManager.fade_out(FADE_DURATION)
			skip_gameover()


func _play_game_over_screen(type: String):
	MusicManager.play_music(game_over)
	gameover.over_anim(type)


func skip_gameover():
	FadeManager.fade_in()
	await get_tree().create_timer(FADE_DURATION).timeout
	get_tree().paused = false
	global_load.load_scene(get_tree().root.get_node("Zone"), GAME_OVER_SCENE)
	_reset_scores()
	ScoreManager.lifes = DEFAULT_LIVES


func skip():
	FadeManager.fade_in()
	await get_tree().create_timer(FADE_DURATION).timeout
	get_tree().paused = false
	global_load.load_scene(get_tree().root.get_node("Zone"), zone_to_reload)
	_reset_scores()


func _reset_scores():
	ScoreManager.reset_score(true, true, true)
	ScoreManager.time_stopped = false
