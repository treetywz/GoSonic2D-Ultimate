extends Node2D

class_name Spring

@export var power: float = 600
@export_enum("Vertical", "Horizontal") var type: int
@export var spring_audio_path: NodePath

@onready var animation_tree = $Sprite2D/AnimationTree
@onready var collider = $SolidObject/CollisionShape2D

@onready var spring_audio = get_node(spring_audio_path) as AudioStreamPlayer

func activate():
	spring_audio.play()
	animation_tree.set("parameters/state/active", true)

func apply_vertical_force(player: Player, direction: int):
	player.velocity.y = power * -direction
	if player.shields.current_shield == player.shields.shields.BubbleShield:
		var bShield = player.shields.get_node("BubbleShield")
		if bShield.descending == true:
			bShield.descending = false
			bShield.set_attacking(false)
			bShield.special_audio.play()
			bShield.animation_player.play("bounce")
	activate()

func apply_horizontal_force(player: Player, direction: int):
	player.lock_controls()
	player.skin.handle_flip(direction)
	player.velocity.x = power * direction
	activate()

func _on_SolidObject_player_right_wall_collision(player: Player):
	if type == 1:
		apply_horizontal_force(player, -1)
	elif type == 0:
		if abs(player.rotation_degrees) == 90:
			apply_horizontal_force(player, -1)

func _on_SolidObject_player_left_wall_collision(player: Player):
	if type == 1:
		apply_horizontal_force(player, 1)
	elif type == 0:
		if abs(player.rotation_degrees) == 90:
			apply_horizontal_force(player, 1)

func _on_SolidObject_player_ground_collision(player: Player):
	if type == 0 and player.velocity.y >= 0:
		player.state_machine.change_state("Spring")
		apply_vertical_force(player, 1)

func _on_SolidObject_player_ceiling_collision(player: Player):
	if type == 0 and player.velocity.y <= 0:
		apply_vertical_force(player, -1)
