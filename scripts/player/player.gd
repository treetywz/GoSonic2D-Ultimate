extends Node2D

class_name Player

# Signals
signal ground_enter
signal super_transform
signal detransform

# Exported properties
@export_enum("Sonic", "Tails", "Knuckles") var player_id: String
@export var bounds: Array[Resource]
@export var stats: Array[Resource]
@export_flags_2d_physics var wall_layer = 1
@export_flags_2d_physics var ground_layer = 1
@export_flags_2d_physics var ceiling_layer = 1
@export var ring: PackedScene
@export var super_music: AudioStream
@export var super_sonic_texture: Texture2D
@export var sonic_texture: Texture2D
@export var super_ring_amount: int

# Node references
@onready var skin = $Skin as PlayerSkin
@onready var state_machine = $StateMachine as PlayerStateMachine
@onready var shields = $Shields as ShieldsManager
@onready var audios = $Audios as PlayerAudio
@onready var initial_parent = get_parent()
@onready var score_manager = get_node("/root/ScoreManager") as ScoreManager
@onready var invis_frame_timer = $iframe_timer

# Raycasts
@onready var raycasts = $LedgeCheckers
@onready var raycastspush = $PushCheckers
@onready var ledge_left = raycasts.get_node("LeftChecker")
@onready var ledge_right = raycasts.get_node("RightChecker")
@onready var ledge_mid = raycasts.get_node("MidChecker")
@onready var ledge_mid_right = raycasts.get_node("MidRightChecker")
@onready var ledge_mid_left = raycasts.get_node("MidLeftChecker")
@onready var left_push = raycastspush.get_node("Left")
@onready var right_push = raycastspush.get_node("Right")
@onready var dash_dust = skin.get_node("SpinDashDust")

# Core variables
var world: World2D
var current_bounds: PlayerCollision
var current_stats: PlayerStats
var collider: Area2D
var collider_shape: RectangleShape2D

# Physics
var velocity: Vector2
var ground_normal: Vector2
var input_direction: Vector2
var ground_angle: float
var absolute_ground_angle: float
var input_dot_velocity: float
var control_lock_timer: float
var control_lock_enabled : bool = true


# Limits
var limit_left: float
var limit_right: float

# State flags
var is_jumping: bool
var is_rolling: bool
var is_pushing: bool
var is_looking_down: bool
var is_looking_up: bool
var is_control_locked: bool
var is_locked_to_limits: bool
var __is_grounded: bool
var delay_cam = false
var colliding = true
var vulnerable = true
var can_collect_rings = true
var has_been_spiked = false
var flashing = false
var iframe_process = false
var super_state = false
var can_transform = false
var spun_sign_post = false

# Ring drop constants
const RING_STARTING_ANGLE = deg_to_rad(101.25)
const RING_DEFAULT_SPEED = 100
const RING_ANGLE_INCREMENT = deg_to_rad(22)

# Invisibility frame constants
const IFRAME_FLASH_INTERVAL = 1.0 / 15.0  # 60fps / 4 = 15 flashes per second

# Ring drop variables
var ring_angle = RING_STARTING_ANGLE
var ring_speed = RING_DEFAULT_SPEED
var ring_flip = false

# Super transformation requirements
var super_em_requirement = globalvars.ch_emerald_super_requirement
var chaos_emeralds = globalvars.chaos_emeralds


func _ready():
	ScoreManager.time_over.connect(_on_time_over)
	dash_dust.visible = false
	initialize_collider()
	initialize_resources()
	initialize_state_machine()
	initialize_skin()


func _physics_process(delta):
	handle_input()
	handle_control_lock(delta)
	handle_state_update(delta)
	handle_motion(delta)
	handle_limits()
	handle_state_animation(delta)
	handle_skin(delta)
	handle_super_sonic()

func _on_time_over():
	if state_machine.current_state != "Dead":
		state_machine.change_state("Dead")

func _process(_delta):
	score_manager.extra_life(self)
	
	# Debug input
	if Input.is_action_just_pressed("player_debug"):
		state_machine.change_state("Dead")
		#iframes()
	
	# Update vulnerability when sign post is spun
	if spun_sign_post:
		vulnerable = false
	
	# Handle transformation availability
	update_transformation_availability()
	
	# Detransform if out of rings
	if ScoreManager.rings == 0 and super_state:
		set_super_state(false)


# Initialization
func initialize_collider():
	var collision = CollisionShape2D.new()
	collider_shape = RectangleShape2D.new()
	collider = Area2D.new()
	collision.shape = collider_shape
	collider.add_child(collision)
	add_child(collider)


func initialize_resources():
	world = get_world_2d()
	set_bounds(0)
	set_stats(0)


func initialize_state_machine():
	state_machine.initialize()


func initialize_skin():
	remove_child(skin)
	get_tree().root.call_deferred("add_child", skin)


# State management
func change_state(state: String):
	state_machine.change_state(state)


func victory_anim():
	while !__is_grounded:
		await get_tree().create_timer(0.1).timeout
	change_state("Victory")


# Super Sonic
func update_transformation_availability():
	if ScoreManager.rings >= super_ring_amount and chaos_emeralds >= super_em_requirement and !spun_sign_post:
		can_transform = !super_state
	else:
		can_transform = false


func handle_super_sonic():
	if super_state:
		set_stats(1)
		skin.set_pallete("super")
		skin.texture = super_sonic_texture
		shields.visible = false
		vulnerable = false
		MusicManager.play_music(super_music)
	else:
		set_stats(0)
		if !skin.transitioning_pallete:
			skin.set_pallete("normal")
		skin.texture = sonic_texture
		
		if state_machine.current_state not in ["Transform", "Dead"]:
			shields.visible = true
		
		# why..? this is completely useless.. it's such a waste of memory.
		# i have no idea what you were thinking, past me.
		#if state_machine.current_state != "Dead" and state_machine.current_state != "Victory":
			#if !spun_sign_post:
				#get_parent()._zone_music()

func set_super_state(value: bool):
	if value:
		super_state = true
		emit_signal("super_transform")
	else:
		if super_state:
			super_state = false
			vulnerable = true
			iframes()
			get_parent()._zone_music()
			emit_signal("detransform")
			if skin.pal_swapper.current_animation != "Detransform":
				skin.transitioning_pallete = true
				skin.pal_swapper.play("Detransform")

# Damage system
func hurt(type: String, hazard):
	if !vulnerable:
		return
	
	ScoreManager.times_hit += 1
	
	if score_manager.rings > 0:
		hurt_routine(type, hazard)
	else:
		if shields.current_shield == shields.shields.InstaShield:
			state_machine.get_node("Dead").typeof_death = type
			state_machine.change_state("Dead")
		else:
			hurt_routine(type, hazard)


func kick_off_board(hazard):
	audios.hurt.play()
	state_machine.get_node("Hurt").launch(self, hazard)
	change_state("Hurt")


func hurt_routine(type: String, hazard):
	if !vulnerable:
		return
	
	state_machine.get_node("Hurt").launch(self, hazard)
	state_machine.change_state("Hurt")
	
	
	if type == "spikes":
		has_been_spiked = true
	
	if shields.current_shield == shields.shields.InstaShield:
		var rings_to_drop = min(32, score_manager.rings)
		drop_rings(rings_to_drop)
		audios.loserings.play()
	else:
		shields.change_to_default()
		audios.hurt.play()


func drop_rings(amount: int):
	score_manager.remove_ring(score_manager.rings)
	
	for i in range(amount):
		var ring_instance = ring.instantiate()
		ring_instance.global_position = global_position
		ring_instance.gravitised = true
		
		# Calculate ring velocity
		var delta_x = ring_speed * cos(ring_angle)
		var delta_y = ring_speed * sin(ring_angle)
		ring_instance.velocity.x = delta_x if !ring_flip else -delta_x
		ring_instance.velocity.y = delta_y
		
		# Update for next ring
		ring_angle += RING_ANGLE_INCREMENT
		ring_flip = !ring_flip
		
		# Reset after half the rings
		if i + 1 == roundi(amount / 2.0):
			ring_speed = RING_DEFAULT_SPEED
			ring_angle = RING_STARTING_ANGLE
		
		get_parent().call_deferred("add_child", ring_instance)


# Invincibility frames
func iframes():

	iframe_process = true
	vulnerable = false

	invis_frame_timer.start()
	
	# Flash the skin while timer is active
	while invis_frame_timer.time_left > 0:
		# Allow ring collection after initial vulnerability period
		if __is_grounded:
			can_collect_rings = true
		
		
		# Toggle visibility
		skin.visible = !skin.visible
		
		# Exit early if super state activated
		if super_state or state_machine.current_state == "Dead":
			skin.visible = true
			break
		
		await get_tree().create_timer(IFRAME_FLASH_INTERVAL).timeout
	
	# Cleanup
	skin.visible = true
	iframe_process = false


func _on_iframe_timer_timeout():
	invis_frame_timer.stop()
	vulnerable = true
	has_been_spiked = false


# Configuration
func set_bounds(index: int):
	if index < 0 or index >= bounds.size():
		return
	
	var last_bounds = current_bounds
	current_bounds = bounds[index]
	collider_shape.size.x = (current_bounds.width_radius + current_bounds.push_radius) * 2
	collider_shape.size.y = current_bounds.height_radius * 2
	position -= current_bounds.offset
	
	if last_bounds and last_bounds != current_bounds:
		position += last_bounds.offset


func set_stats(index: int):
	if index >= 0 and index < stats.size():
		current_stats = stats[index]


func get_player_position():
	var y_offset = transform.y * current_bounds.offset.y
	var x_offset = transform.x * current_bounds.offset.x
	return global_position + y_offset + x_offset


func is_grounded():
	return __is_grounded and velocity.y >= 0


# Input handling
func handle_input():
	var right = Input.is_action_pressed("player_right")
	var left = Input.is_action_pressed("player_left")
	var up = Input.is_action_pressed("player_up")
	var down = Input.is_action_pressed("player_down")
	var horizontal = 1 if right else (-1 if left else 0)
	var vertical = 1 if up else (-1 if down else 0)
	horizontal = 0 if is_control_locked else horizontal
	input_direction = Vector2(horizontal, vertical)
	input_dot_velocity = input_direction.dot(velocity)


func lock_controls():
	if !is_control_locked and control_lock_enabled:
		input_direction.x = 0
		is_control_locked = true
		control_lock_timer = current_stats.control_lock_duration


func unlock_controls():
	if is_control_locked:
		is_control_locked = false
		control_lock_timer = 0


func handle_control_lock(delta: float):
	if !is_control_locked:
		return
	
	input_direction.x = 0
	if __is_grounded:
		control_lock_timer -= delta
		if abs(velocity.x) == 0 or control_lock_timer <= 0:
			unlock_controls()


# Physics updates
func handle_state_update(delta: float):
	state_machine.update_state(delta)


func handle_motion(delta: float):
	var offset = velocity.length() * delta
	var max_motion_size = current_bounds.width_radius
	var motion_steps = ceil(offset / max_motion_size)
	var step_motion = velocity / motion_steps

	for i in range(motion_steps):
		apply_motion(step_motion, delta)
		handle_collision()


func apply_motion(desired_velocity: Vector2, delta: float):
	if !colliding:
		position += desired_velocity * delta
		return
	
	if __is_grounded:
		var global_velocity = GoUtils.ground_to_global_velocity(desired_velocity, ground_normal)
		position += global_velocity * delta
	else:
		position += desired_velocity * delta


func handle_collision():
	handle_wall_collision()
	handle_ground_collision()
	handle_ceiling_collision()


func handle_wall_collision():
	if !colliding:
		return
	
	var ray_size = current_bounds.width_radius + current_bounds.push_radius
	var origin = global_position + transform.y * current_bounds.push_height_offset if __is_grounded and absolute_ground_angle < 10 else global_position
	var right_ray = GoPhysics.cast_ray(world, origin, transform.x, ray_size, [self], wall_layer)
	var left_ray = GoPhysics.cast_ray(world, origin, -transform.x, ray_size, [self], wall_layer)

	if right_ray:
		handle_contact(right_ray.collider, "player_right_wall_collision")
		
		if not right_ray.collider is SolidObject or right_ray.collider.is_enabled():
			velocity.x = min(velocity.x, 0)
			position -= transform.x * (right_ray.penetration + GoPhysics.EPSILON)
	
	if left_ray:
		handle_contact(left_ray.collider, "player_left_wall_collision")
		
		if not left_ray.collider is SolidObject or left_ray.collider.is_enabled():
			velocity.x = max(velocity.x, 0)
			position += transform.x * (left_ray.penetration + GoPhysics.EPSILON)


func handle_ceiling_collision():
	if !colliding:
		return
	
	var ray_size = current_bounds.height_radius
	var ray_offset = transform.x * current_bounds.width_radius
	var hits = GoPhysics.cast_parallel_rays(world, global_position, ray_offset, -transform.y, ray_size, [self], ceiling_layer)
	
	if !hits or velocity.y > 0:
		return
	
	handle_contact(hits.closest_hit.collider, "player_ceiling_collision")
	
	if __is_grounded or (hits.closest_hit.collider is SolidObject and !hits.closest_hit.collider.is_enabled()):
		return
	
	var ceiling_normal = hits.closest_hit.normal
	var ceiling_angle = GoUtils.get_angle_from(ceiling_normal)

	if abs(ceiling_angle) < 135:
		set_ground_data(ceiling_normal)
		rotate_to(ceiling_angle)
		enter_ground(hits.closest_hit)
	else:
		velocity.y = 0
	
	position += transform.y * hits.closest_hit.penetration


func handle_ground_collision():
	if !colliding:
		return
	
	var ray_offset = transform.x * current_bounds.width_radius
	var ray_size = current_bounds.height_radius + current_bounds.ground_extension if __is_grounded else current_bounds.height_radius
	var hits = GoPhysics.cast_parallel_rays(world, global_position, ray_offset, transform.y, ray_size, [self], ground_layer)

	if hits and velocity.y >= 0:
		handle_contact(hits.closest_hit.collider, "player_ground_collision")
		
		if not hits.closest_hit.collider is SolidObject or hits.closest_hit.collider.is_enabled():
			if not __is_grounded and velocity.y >= 0:
				set_ground_data(hits.closest_hit.normal)
				rotate_to(ground_angle)
				position -= transform.y * hits.closest_hit.penetration
				enter_ground(hits.closest_hit)
			elif hits.left_hit or hits.right_hit:
				var safe_distance = hits.closest_hit.penetration - current_bounds.ground_extension
				set_ground_data(hits.closest_hit.normal)
				rotate_to(ground_angle)
				position -= transform.y * safe_distance
	else:
		exit_ground()


func handle_contact(static_body: Variant, signal_name: String):
	if static_body is SolidObject:
		static_body.emit_signal(signal_name, self)


func handle_platform(platform_collider: Variant):
	if __is_grounded and platform_collider is MovingPlatform:
		change_parent(platform_collider)
	else:
		change_parent(initial_parent)


func set_ground_data(normal: Vector2 = Vector2.UP):
	ground_normal = normal
	ground_angle = GoUtils.get_angle_from(normal)
	absolute_ground_angle = abs(ground_angle)


func rotate_to(angle: float):
	var closest_angle = snapped(angle, 90)
	rotation_degrees = closest_angle


func enter_ground(ground_data: Dictionary):
	if !colliding or __is_grounded:
		return
	
	is_jumping = false
	is_rolling = false
	__is_grounded = true
	velocity = GoUtils.global_to_ground_velocity(velocity, ground_normal)
	handle_platform(ground_data.collider)
	emit_signal("ground_enter")


func exit_ground():
	if !colliding or !__is_grounded:
		return
	
	__is_grounded = false
	change_parent(initial_parent)
	velocity = GoUtils.ground_to_global_velocity(velocity, ground_normal)
	rotate_to(0)


# Movement mechanics
func handle_fall():
	if __is_grounded and absolute_ground_angle > current_stats.slide_angle and abs(velocity.x) <= current_stats.min_speed_to_fall:
		lock_controls()

		if absolute_ground_angle > current_stats.fall_angle:
			exit_ground()


func handle_slope(delta: float):
	if !__is_grounded:
		return
	
	var down_hill = velocity.dot(ground_normal) > 0
	var rolling_factor = current_stats.slope_roll_down if down_hill else current_stats.slope_roll_up
	var amount = rolling_factor if is_rolling else current_stats.slope_factor
	velocity.x += amount * ground_normal.x * delta


func handle_gravity(delta: float):
	if !__is_grounded:
		velocity.y += current_stats.gravity * delta


func handle_acceleration(delta: float):
	if input_direction.x == 0:
		return
	
	if sign(input_direction.x) == sign(velocity.x) or !__is_grounded:
		var amount = current_stats.acceleration if __is_grounded else current_stats.air_acceleration
		if abs(velocity.x) < current_stats.top_speed:
			velocity.x += input_direction.x * amount * delta
			velocity.x = clamp(velocity.x, -current_stats.top_speed, current_stats.top_speed)
	else:
		velocity.x += input_direction.x * current_stats.deceleration * delta


func handle_deceleration(delta: float):
	if input_direction.x != 0 and sign(input_direction.x) != sign(velocity.x):
		var amount = current_stats.roll_deceleration if is_rolling else current_stats.deceleration
		velocity.x = move_toward(velocity.x, 0, amount * delta)


func handle_friction(delta: float):
	if __is_grounded and (input_direction.x == 0 or is_rolling):
		var amount = current_stats.roll_friction if is_rolling else current_stats.friction
		velocity.x = move_toward(velocity.x, 0, amount * delta)


func handle_jump():
	if __is_grounded and (Input.is_action_just_pressed("player_a") or Input.is_action_just_pressed("player_b")):
		is_jumping = true
		is_rolling = true
		audios.jump_audio.play()
		velocity.y = -current_stats.max_jump_height

	if is_jumping and (Input.is_action_just_released("player_a") or Input.is_action_just_released("player_b")) and velocity.y < -current_stats.min_jump_height:
		velocity.y = -current_stats.min_jump_height


# Limits and boundaries
func handle_limits():
	if !is_locked_to_limits:
		return
	
	var offset = current_bounds.width_radius
	if global_position.x + offset > limit_right:
		global_position.x = limit_right - offset
		velocity.x = 0
	if global_position.x - offset < limit_left:
		global_position.x = limit_left + offset
		velocity.x = 0


func lock_to_limits(left: float, right: float):
	limit_left = left
	limit_right = right
	is_locked_to_limits = true


# Visual updates
func handle_state_animation(delta):
	state_machine.animate_state(delta)


func handle_skin(delta):
	skin.position = global_position
	
	if is_rolling or abs(velocity.x) == 0:
		skin.rotation_degrees = 0
		return
	
	if !__is_grounded:
		var current_rotation = skin.rotation_degrees
		skin.rotation_degrees = move_toward(current_rotation, 0, 360 * delta)
	else:
		skin.rotation_degrees = round(ground_angle) if abs(ground_angle) > 10 else 0.0


# Utility
func change_parent(new_parent: Node):
	var current_parent = get_parent()
	if new_parent == current_parent:
		return
	
	var old_transform = global_transform
	current_parent.remove_child(self)
	new_parent.add_child(self)
	global_transform = old_transform
