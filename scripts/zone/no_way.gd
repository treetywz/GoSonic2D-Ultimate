extends Control

@export var music: AudioStream
@export var delay: bool = false

var activated_godot: bool = false

@onready var start_node = $Start
@onready var start_anim = $Start/AnimationPlayer
@onready var sound = $sound

func _ready():
	Global.current_act = 1
	
	if !delay:
		GoData.load_file()
		UI.fade_out()
		MusicManager.play_music(music)
		start_node.visible = true

func _process(_delta):
	if delay:
		if Input.is_action_just_pressed("player_a"):
			delay = false
			_ready()
		return
	
	if Input.is_action_just_pressed("player_a") or Input.is_action_just_pressed("ui_accept"):
		if !activated_godot:
			_start_game()

func _start_game():
	activated_godot = true
	start_anim.play("blink")
	sound.play()
	
	await get_tree().create_timer(2.0).timeout
	
	UI.fade_in()
	MusicManager.fade_out(2.0)
	
	await get_tree().create_timer(2.0).timeout
	
	ScoreManager.reset_score(true, true, true)
	ScoreManager.time_stopped = false
	LoadingScreen.load_scene(self, "res://scenes/main.tscn")
