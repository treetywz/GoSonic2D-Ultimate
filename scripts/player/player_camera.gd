extends Camera2D

class_name PlayerCamera

@export var high_velocity_speed: float = 960.00
@export var low_velocity_speed: float = 360.00
@export var high_velocity_xsp: float = 480.00
@export var right_margin: float = 0.00
@export var left_margin: float = -16.00
@export var top_margin: float = -32.00
@export var bottom_margin: float = 32.00

var player: Player

var delay_timer: float = 0
var is_delaying: bool = false
var delay_duration: float = 0.26666666666
var original_target_position: Vector2
var scrolled_up = false
var scrolled_down = false

var stop_scroll = ""

func _ready():
	initialize_camera()

func _physics_process(delta):
	#if player.is_rolling:
	#	offset.y = -5
	#else:
	#	offset.y = 0
	
	if delay_timer > 0:
		delay_timer -= delta
		if delay_timer <= 0:
			original_target_position = Vector2.ZERO
	else:
		handle_horizontal_borders(delta)
		handle_vertical_borders(delta)
		
	if player.delay_cam == true:
		player.delay_cam = false
		start_camera_delay()
		
	if player.is_looking_up:
		if stop_scroll == "back":
			var time = 0
			while time < 2:
				await get_tree().create_timer(0.1).timeout
				time += 0.1
				if !player.is_looking_up:
					time = 0
					break
		if player.is_looking_up:
			if !stop_scroll == "up":
				scroll("up")
	elif player.is_looking_down:
		if stop_scroll == "back":
			var time = 0
			while time < 2:
				await get_tree().create_timer(0.1).timeout
				time += 0.1
				if !player.is_looking_down:
					time = 0
					break
		if player.is_looking_down: # may look dumb, but its to check if player is still looking down.
			if !stop_scroll == "down":
				scroll("down")
		
	else:
		if !stop_scroll == "back":
			scroll("back")
func initialize_camera():
	enabled = true

func scroll(direction: String):
	stop_scroll = direction

	# Determine the target offset based on the direction
	var target_offset = Vector2()
	if direction == "up":
		target_offset.y = -104
		scrolled_up = true
		scrolled_down = false
	elif direction == "down":
		target_offset.y = 88
		scrolled_up = false
		scrolled_down = true

	# Scroll towards the target offset
	while offset.y != target_offset.y:
		var step = 2 * sign(target_offset.y - offset.y)
		offset.y += step
		await get_tree().create_timer(0.01).timeout

	# Check if scrolling needs to be stopped
		if stop_scroll != direction:
			break

	# Reset scrolled flags
	scrolled_up = false
	scrolled_down = false
	
func set_player(desired_player: Player):
	player = desired_player
	position = player.global_position

func set_limits(left: int, right: int, top: int, bottom: int):
	limit_left = left
	limit_right = right
	limit_top = top
	limit_bottom = bottom
	
func set_limits_from_resource(limits: CameraLimits, change_limit_left : bool = false):
	if change_limit_left:
		limit_left = limits.limit_left
	limit_right = limits.limit_right
	limit_top = limits.limit_top
	limit_bottom = limits.limit_bottom

func tween_limits(left: int, right: int, top: int, bottom: int, duration: float = 2, change_limit_left : bool = false):
	var tween = create_tween()
	tween.set_parallel(true)  # All tweens happen at the same time
	
	if change_limit_left:
		tween.tween_property(self, "limit_left", left, duration)
	tween.tween_property(self, "limit_right", right, duration)
	tween.tween_property(self, "limit_top", top, duration)
	tween.tween_property(self, "limit_bottom", bottom, duration)
	
	return tween

func tween_limits_from_resource(limits: CameraLimits, duration: float = 2, change_limit_left : bool = false):
	var tween = create_tween()
	tween.set_parallel(true)
	
	if change_limit_left:
		tween.tween_property(self, "limit_left", limits.limit_left, duration)
	tween.tween_property(self, "limit_right", limits.limit_right, duration)
	tween.tween_property(self, "limit_top", limits.limit_top, duration)
	tween.tween_property(self, "limit_bottom", limits.limit_bottom, duration)
	
	return tween

func handle_horizontal_borders(delta: float):
	var target = player.get_player_position().x
	
	if target > position.x + right_margin:
		var _offset = target - position.x - right_margin
		position.x += min(_offset, high_velocity_speed * delta)
	
	if target < position.x + left_margin:
		var _offset = target - position.x - left_margin
		position.x += max(_offset, -high_velocity_speed * delta)

func handle_vertical_borders(delta: float):
	var target = player.get_player_position().y
	
	if player.is_grounded():
		var _offset = target - position.y
		var is_at_high_velocity = player.velocity.x <= high_velocity_xsp
		var speed = low_velocity_speed if is_at_high_velocity else high_velocity_speed
		position.y += clamp(_offset, -speed * delta, speed * delta)
	else:
		if target < position.y + top_margin :
			var _offset = target - position.y - top_margin
			position.y += max(_offset, -high_velocity_speed * delta)
		
		if target > position.y + bottom_margin:
			var _offset = target - position.y - bottom_margin
			position.y += min(_offset, high_velocity_speed * delta)

func start_camera_delay():
	delay_timer = delay_duration
	original_target_position = player.get_position()
#func _draw():
#	var right = Vector2.RIGHT * right_margin
#	var left = Vector2.RIGHT * left_margin
#	var top_left = Vector2.UP * -top_margin + left
#	var top_right = Vector2.UP * -top_margin + right
#	var bottom_left = Vector2.DOWN * bottom_margin + left
#	var bottom_right = Vector2.DOWN * bottom_margin + right
#	draw_line(top_left, bottom_left, Color.white)
#	draw_line(top_right, bottom_right, Color.white)
#	draw_line(top_left, top_right, Color.white)
#	draw_line(bottom_left, bottom_right, Color.white)
#	draw_line(right, left, Color.green)

func _on_area_entered(area):
	if area.get_parent() is Player:
		if !player.state_machine.current_state == "Dead" and !player.state_machine.current_state == "Snowboarding":
			player.state_machine.change_state("Dead")
