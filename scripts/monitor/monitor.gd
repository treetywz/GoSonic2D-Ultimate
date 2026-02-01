extends Node2D
class_name Monitor

@export var bump_force: float = 150
@export var gravity: float = 700
@export var ground_distance: float = 16
@export var shield: bool
@export var life_monitor: bool
@export_flags_2d_physics var ground_layer = 1
@export_enum("BlueShield", "ThunderShield", "FlameShield", "BubbleShield", "Super") var shield_type: String

@onready var tree = get_tree()
@onready var world = get_world_2d()
@onready var icon = $Icon
@onready var explosion = $Explosion0
@onready var solid_object = $SolidObject
@onready var animation_tree = $Sprite2D/AnimationTree
@onready var score_controller = $ScoreController
@onready var item_audio = $Audios/ItemAudio
@onready var explosion_audio = $Audios/ExplosionAudio

var velocity: Vector2
var destroyed: bool
var allow_movement: bool

func _ready():
	# Ensure AnimationTree is active
	animation_tree.active = true

func _physics_process(delta):
	if allow_movement:
		handle_movement(delta)
		handle_collision()

func handle_movement(delta: float):
	velocity.y += gravity * delta
	position += velocity * delta

func handle_collision():
	var ground_hit = GoPhysics.cast_ray(world, position, transform.y, 
		ground_distance, [solid_object], ground_layer)
	
	if ground_hit:
		allow_movement = false
		velocity = Vector2.ZERO
		position.y -= ground_hit.penetration
		position = position.round()

func destroy(player):
	if not destroyed:
		destroyed = true
		explosion.play()
		
		if player.shields.current_shield == player.shields.shields.BubbleShield:
			var bShield = player.shields.get_node("BubbleShield")
			if bShield.descending == true:
				bShield.descending = false
				bShield.set_attacking(false)
				bShield.special_audio.play()
				bShield.animation_player.play("bounce")
		
		icon.set_movement(true)
		explosion_audio.play()
		solid_object.set_enabled(false)
		
		var playback = animation_tree.get("parameters/playback")
		if playback:
			playback.travel("destroyed")
		else:
			animation_tree.set("parameters/state/transition_request", "destroyed")
		
		handle_item(player)

func handle_item(player):
	await tree.create_timer(0.5).timeout
	item_audio.play()
	
	if shield:
		score_controller.add_score(player)
	else:
		score_controller.add_score()

func bump_up():
	allow_movement = true
	z_index = 0
	velocity.y = -bump_force

func _on_SolidObject_player_ceiling_collision(player: Player):
	if player.velocity.y <= 0:
		bump_up()
	elif player.state_machine.current_state == "Snowboarding":
		destroy(player)

func _on_SolidObject_player_ground_collision(player: Player):
	if player.is_rolling and player.velocity.y > 0:
		player.velocity.y = -player.velocity.y
		destroy(player)
	elif player.state_machine.current_state == "Snowboarding":
		destroy(player)

func _on_SolidObject_player_left_wall_collision(player: Player):
	if player.is_grounded() and player.is_rolling:
		destroy(player)
	elif player.state_machine.current_state == "Snowboarding":
		destroy(player)

func _on_SolidObject_player_right_wall_collision(player: Player):
	if player.is_grounded() and player.is_rolling:
		destroy(player)
	elif player.state_machine.current_state == "Snowboarding":
		destroy(player)
