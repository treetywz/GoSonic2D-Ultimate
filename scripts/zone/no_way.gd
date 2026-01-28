extends Control

@export var music: AudioStream
@export var godot: Texture2D
@export var demo_start: Texture2D

var activated_godot : bool = false
var loop = true

func _ready():
	go_data.load_file()
	FadeManager.fade_out()
	MusicManager.play_music(music)
	$Start.visible = true
	
func _process(_delta):
	if (Input.is_action_just_pressed("player_a") or Input.is_action_just_pressed("ui_accept")) and !activated_godot:
		$Start/AnimationPlayer.play("blink")
		$sound.play()
		await get_tree().create_timer(2).timeout
		FadeManager.fade_in()
		MusicManager.fade_out(2)
		await get_tree().create_timer(2).timeout
		global_load.load_scene(self,"res://scenes/main.tscn")
		ScoreManager.reset_score(true, true, true)
		ScoreManager.time_stopped_goal = false
