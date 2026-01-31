extends CharacterBody2D
class_name Ring

# Constants
const TURN_SPEED = 0.5
const FOLLOW_SPEED = 0.3
const GRAVITY = 16
const BOUNCE_INITIAL = 500
const BOUNCE_DAMP = 100
const BOUNCE_CHANCE = 0.9

# Node References
@onready var sprite = $Sprite2D
@onready var collider = $Area2D/CollisionShape2D
@onready var collision_body = $Collision
@onready var score_controller = $ScoreController
@onready var ring_sparkle = $RingSparkle
@onready var despawn_timer = $despawn
@onready var fade_animation = $fade

# State Variables
@export var gravitised = false
var magnetised = false
var collected = false

# Physics
var bounce = BOUNCE_INITIAL
var x_speed: float = 0.0
var y_speed: float = 0.0

# References
var _player: Player
var _rng: RandomNumberGenerator


func _ready():
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	
	if gravitised:
		despawn_timer.start()


func _physics_process(_delta):
	if collected:
		return
	
	if magnetised:
		_handle_magnetism()
	
	if gravitised:
		_handle_gravity()


func collect(player: Player):
	if collected:
		return
	
	collected = true
	gravitised = false
	magnetised = false
	
	player.audios.ring_audio.play()
	ring_sparkle.play()
	sprite.visible = false
	score_controller.add_score()
	collider.set_deferred("disabled", true)
	
	# Delete after sparkle animation finishes
	await ring_sparkle.animation_player.animation_finished
	queue_free()

func _gravitise():
	gravitised = true
	despawn_timer.start()
	print(despawn_timer)

func _handle_magnetism():
	if !_player:
		return
	elif _player.shields.current_shield != _player.shields.shields.ThunderShield:
		_gravitise()
		magnetised = false
		return
	
	var direction_to_player = (_player.position - position).sign()
	
	# Use TURN_SPEED when turning around (signs differ), FOLLOW_SPEED when following (signs match)
	var acceleration_x = TURN_SPEED if sign(x_speed) != direction_to_player.x else FOLLOW_SPEED
	var acceleration_y = TURN_SPEED if sign(y_speed) != direction_to_player.y else FOLLOW_SPEED
	
	x_speed += acceleration_x * direction_to_player.x
	y_speed += acceleration_y * direction_to_player.y
	
	position += Vector2(x_speed, y_speed)


func _handle_gravity():
	velocity.y += GRAVITY
	
	if is_on_floor():
		if Global.ring_drop:
			if _should_bounce():
				_bounce()
			else:
				collision_body.set_deferred("disabled", true)
		else:
			_bounce()
	
	move_and_slide()


func _bounce():
	velocity.y -= bounce
	bounce = max(0, bounce - BOUNCE_DAMP)


func _should_bounce() -> bool:
	return _rng.randf() <= BOUNCE_CHANCE


func _on_Area2D_area_entered(area):
	if collected:
		return
	
	var parent = area.get_parent()
	
	if parent is Player and parent.can_collect_rings:
		collect(parent)
	elif parent.name == "ThunderShield":
		_player = parent.player
		magnetised = true


func _on_despawn():
	despawn_timer.stop()
	
	if fade_animation.current_animation != "fade":
		fade_animation.play("fade")
	
	collider.set_deferred("disabled", true)


func _on_fade_animation_finished(_anim_name):
	if collider.disabled:
		queue_free()
