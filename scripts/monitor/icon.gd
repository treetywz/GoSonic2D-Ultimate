extends Sprite2D

@export var move_height: float = 50
@export var move_speed: float = 130
@export var visible_time: float = 1

var destination: Vector2
var movement: bool
var visible_timer: float

@onready var iconswap = get_node_or_null("IconSwapper")
@onready var shield_type = get_parent().shield_type
@onready var zone = Global.find_zone_from_root()

func _ready():
	
	destination = Vector2.UP * move_height
	if get_parent().shield == true:
		iconswap.play(shield_type)

func _get_life_icon(id, supr):
	var to_load = str("res://sprites/hud/life_icons/", id, ".png")
	var to_load_super = str("res://sprites/hud/life_icons/Super", id, "Monitor.png")
	if ResourceLoader.exists(to_load_super) and supr:
		return load(to_load_super)
	elif !ResourceLoader.exists(to_load):
		push_warning("HUD: There was no file found at '%s'!" % to_load)
		return
	return load(to_load)

func _process(delta):
	if movement:
		handle_movement(delta)
		handle_visibility(delta)
	if get_parent().life_monitor == true:
		
		if zone.player != null:
			var player = zone.player
			hframes = 1
			vframes = 1
			texture = _get_life_icon(player.player_id, player.super_state)
				
func handle_movement(delta: float):
	var speed = move_speed * delta
	position = position.move_toward(destination, speed)

func handle_visibility(delta: float):
	if visible_timer <= visible_time:
			visible_timer += delta
	else:
		visible_timer = 0
		visible = false

func set_movement(value: bool):
	movement = value
