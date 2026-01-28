extends Shield

@export var horizontal_force: float = 480
@export var attacking_sprite_offset: float = -12

@onready var shield_sprite = $ShieldSprite
@onready var attacking_sprite = $AttackingSprite

@onready var shield_animation_player = $ShieldSprite/AnimationPlayer
@onready var attacking_animation_player = $AttackingSprite/AnimationPlayer

func on_activate():
	set_attacking(false)
	shield_user.connect("ground_enter", Callable(self, "on_user_ground_enter"))

func on_deactivate():
	shield_sprite.visible = false
	attacking_sprite.visible = false
	shield_animation_player.stop()
	attacking_animation_player.stop()

func on_action():
	if !shield_user.super_state:
		var direction = -1 if shield_user.skin.flip_h else 1
		shield_user.velocity.x = horizontal_force * direction
		shield_user.velocity.y = 0
		attacking_sprite.offset.x = attacking_sprite_offset * direction
		attacking_sprite.flip_h = shield_user.skin.flip_h
		shield_user.delay_cam = true
		set_attacking(true)

func set_attacking(value: bool):
	attacking_sprite.visible = value
	shield_sprite.visible = not value
	
	if value:
		shield_animation_player.stop()
		attacking_animation_player.play("default")
	else:
		attacking_animation_player.stop()
		shield_animation_player.play("default")

func on_user_ground_enter():
	if get_parent().current_shield == get_parent().shields.FlameShield:
		set_attacking(false)
		if !shield_user.super_state:
			shield_user.state_machine.change_state("Regular") # literally the fix for the glitch lmao
