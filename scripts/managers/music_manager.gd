extends Node

@onready var stream = $Stream
@onready var extra_life = $ExtraLife

const STREAM_VOLUME = 2.5
const MIN_VOLUME = -36
const FADE_INTERVAL = 0.1

var fading: bool = false

func _ready():
	stream.volume_db = STREAM_VOLUME

func play_music(music):
	print("Requested music.")
	stream.volume_db = STREAM_VOLUME
	if stream.stream != music:
		stream.stop()
		stream.stream = music
		stream.play()

func stop_music():
	stream.stop()
	stream.stream = null

func fade_out(speed: float):
	fading = true
	
	while stream.volume_db > MIN_VOLUME and fading:
		await get_tree().create_timer(FADE_INTERVAL).timeout
		stream.volume_db = max(stream.volume_db - speed, MIN_VOLUME)
	
	fading = false

func fade_in(speed: float):
	fading = true
	
	while stream.volume_db < STREAM_VOLUME and fading:
		await get_tree().create_timer(FADE_INTERVAL).timeout
		stream.volume_db = min(stream.volume_db + speed, STREAM_VOLUME)
	
	fading = false

func extra_life_jingle():
	stream.volume_db = MIN_VOLUME
	extra_life.play()
	
	while extra_life.is_playing():
		await get_tree().create_timer(FADE_INTERVAL).timeout
	
	while stream.volume_db < STREAM_VOLUME:
		await get_tree().create_timer(FADE_INTERVAL).timeout
		
		if extra_life.is_playing():
			stream.volume_db = MIN_VOLUME
			break
		
		stream.volume_db = min(stream.volume_db + 4, STREAM_VOLUME)

func reset_volume():
	fading = false
	stream.volume_db = STREAM_VOLUME

func replay_music():
	stream.stop()
	stream.play()

func is_playing():
	return stream.is_playing()
