extends Node

@onready var stream = $Stream
@onready var extra_life = $ExtraLife

var stream_volume = 2.5
var fading : bool

func _ready():
	stream.volume_db = stream_volume

func play_music(music):
	if not stream.stream == music:
		stream.stop()
		stream.stream = music
		stream.play()
func stop_music():
	stream.stop()

func fade_out(speed : float):
	fading = true
	while stream.volume_db > -36:
		await get_tree().create_timer(0.1).timeout
		stream.volume_db -= speed
		if stream.volume_db < -36:
			stream.volume_db = -36
			break
	fading = false
	
func fade_in(speed : float):
	fading = true
	while stream.volume_db < stream_volume:
		await get_tree().create_timer(0.1).timeout
		stream.volume_db += speed
		if stream.volume_db > stream_volume:
			stream.volume_db = stream_volume
			break
	fading = false

func extra_life_jingle():
	stream.volume_db = -36
	extra_life.play()
	while extra_life.is_playing():
		await get_tree().create_timer(0.1).timeout
	while stream.volume_db < stream_volume:
		await get_tree().create_timer(0.1).timeout
		stream.volume_db += 4
		if extra_life.is_playing():
			stream.volume_db = -36
			break
		if stream.volume_db > stream_volume:
			stream.volume_db = stream_volume
	
func reset_volume():
	stream.volume_db = stream_volume

func replay_music():
	stream.stop()
	stream.play()

func is_playing():
	return stream.is_playing()
