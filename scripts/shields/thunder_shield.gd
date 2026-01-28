extends Shield

class_name ThunderShield

@export var vertical_force: float = -330

@onready var sprite = $Sprite2D
@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var collision = $Magnetize/CollisionShape2D

@onready var player = get_parent().get_parent()

var particle = preload("res://objects/particles/electric_sparkles.tscn")

func _ready():
	sprite.visible = false
	collision.set_deferred("disabled", true)

func on_activate():
	sprite.visible = true
	animation_player.play("default")
	collision.set_deferred("disabled", false)

func on_deactivate():
	sprite.visible = false
	animation_player.stop()
	collision.set_deferred("disabled", true)

func on_action():
	if !shield_user.super_state:
		shield_user.velocity.y = vertical_force
		var sparkle = particle.instantiate()
		sparkle.global_position = player.global_position
		player.get_parent().add_child(sparkle)
