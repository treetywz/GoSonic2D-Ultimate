extends Shield

@onready var sprite = $Sprite2D
@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var collision = $Area2D/CollisionShape2D

func _ready():
	set_attacking(false)

func on_action():
	if !shield_user.super_state:
		set_attacking(true)
		animation_player.play("default")
		await animation_player.animation_finished
		set_attacking(false)

func set_attacking(value: bool):
	invincible = value
	sprite.visible = value
	collision.set_deferred("disabled", not value)
