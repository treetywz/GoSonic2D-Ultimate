extends Node2D
class_name AIController

@onready var zone = Global.find_zone_from_root() as Zone
@onready var player : Player
@onready var ai : Player = get_parent()

# 0 = away, 1 = close, 2 = panic, 3 = flying
var state = 0

# Panic spindash internal state
var panic_waiting_for_standstill := false
var panic_spindash_charge_timer := 0
var panic_spindash_release_timer := 0
var panic_spindashing := false

var force_pulling_ai := false

const SPINDASH_CHARGE_INTERVAL := 16
const SPINDASH_RELEASE_INTERVAL := 64

func _ready() -> void:
	ai.enable_artificial_input()
	ai.invincible_but_hurtable = true
	ai.can_break_monitors = false
	ai.lock_to_limits(0, 2607)

# --- State Handlers ---

func handle_away_from_player_state():
	var distance = ai.global_position.distance_to(player.global_position)

	if distance <= 64:
		state = 1
		return

	# Stuck on slope with no ground speed → Panic Spindash
	if ai.is_control_locked and floor(ai.velocity) == Vector2.ZERO:
		enter_panic_spindash()
		return

	handle_copy_inputs()
	handle_pull_toward_player()

func handle_close_to_player_state():
	var distance = ai.global_position.distance_to(player.global_position)

	if distance > 64:
		state = 0
		return

	# Stuck on slope check still applies when close
	if ai.is_control_locked and floor(ai.velocity) == Vector2.ZERO:
		enter_panic_spindash()
		return

	handle_copy_inputs()
	handle_pull_toward_player()

func handle_panic_spindash():
	# Step 1: Wait until AI is at a standstill
	if floor(ai.velocity) != Vector2.ZERO:
		ai.artificial_move_left  = false
		ai.artificial_move_right = false
		ai.artificial_look_up    = false
		ai.artificial_look_down  = false
		ai.artificial_jump         = false
		ai.artificial_jump_release = false
		return

	# Step 2: Face player
	var facing_player_left = player.global_position.x < ai.global_position.x
	ai.artificial_move_left  = facing_player_left
	ai.artificial_move_right = !facing_player_left

	# Step 3: If not yet spindashing, crouch and prepare for spindash
	if !panic_spindashing:
		ai.artificial_look_down = true
		await get_tree().create_timer(0.2).timeout
		panic_spindashing = true
		panic_spindash_charge_timer = 0
		panic_spindash_release_timer = 0
		return

	# Step 4: Charge every 32 frames
	panic_spindash_charge_timer += 1
	panic_spindash_release_timer += 1

	ai.artificial_jump = (panic_spindash_charge_timer % SPINDASH_CHARGE_INTERVAL == 0)

	# Step 5: Release after 128 frames
	if panic_spindash_release_timer >= SPINDASH_RELEASE_INTERVAL:
		ai.artificial_look_down  = false
		ai.artificial_jump_release = true
		ai.clear_artificial_inputs()
		exit_panic_spindash()
		
func handle_flying():
	var x_distance = abs(player.global_position.x - ai.global_position.x)
	ai.being_hanged_onto = player.hanging_object == ai
	if player.hanging_object == ai:
		ai.artificial_move_left    = Input.is_action_pressed("player_left")
		ai.artificial_move_right   = Input.is_action_pressed("player_right")
		ai.artificial_look_up      = Input.is_action_pressed("player_up")
		ai.artificial_look_down    = Input.is_action_pressed("player_down")
	elif !floor(x_distance) == 0:
		var ai_is_left = ai.global_position.x < player.global_position.x
		if ai_is_left:
			ai.artificial_move_right = true
			ai.artificial_move_left = false
		elif !ai_is_left:
			ai.artificial_move_left = true
			ai.artificial_move_right = false
	ai.artificial_jump         = Input.is_action_pressed("player_a")
	ai.artificial_jump_release = Input.is_action_just_released("player_a")
	if ai.__is_grounded:
		state = 1

# --- Helpers ---

func enter_panic_spindash():
	state = 2
	panic_waiting_for_standstill = true
	panic_spindashing = false
	panic_spindash_charge_timer = 0
	panic_spindash_release_timer = 0

func exit_panic_spindash():
	state = 0
	panic_spindashing = false
	panic_spindash_charge_timer = 0
	panic_spindash_release_timer = 0
	ai.artificial_jump_release = false

func force_jump():
	if ai.__is_grounded:
		ai.audios.jump_audio.play()
		ai.is_rolling = true
		ai.velocity.y = -get_random_jump_height()

func handle_copy_inputs():
	if !force_pulling_ai:
		var frame = player.get_delayed_input()
		ai.artificial_move_left    = frame.move_left
		ai.artificial_move_right   = frame.move_right
		ai.artificial_look_up      = frame.look_up
		ai.artificial_look_down    = frame.look_down
		ai.artificial_jump         = frame.jump_pressed
		ai.artificial_jump_release = frame.jump_released

func handle_pull_toward_player():
	var distance = ai.global_position.distance_to(player.global_position)
	var x_distance = abs(player.global_position.x - ai.global_position.x)
	if (check_if_any_inputs_pressed() or distance < 20 or floor(x_distance) == 0) and distance < 200:
		force_pulling_ai = false
		return
	elif distance > 256:
		force_pulling_ai = true

	var ai_is_left = ai.global_position.x < player.global_position.x

	if ai_is_left:
		# Player moving right toward AI, pull AI right
		ai.artificial_move_right = true
		ai.artificial_move_left = false
	elif !ai_is_left:
		# Player moving left toward AI, pull AI left
		ai.artificial_move_left = true
		ai.artificial_move_right = false
		
	if ai.velocity == Vector2.ZERO:
		if Engine.get_physics_frames() % 64 == 0:
			force_jump()

func handle_wall_push_jump():
	# If AI is pushing a wall and player isn't, try to jump out
	# Jump every 64 frames when not crouching or looking up
	if ai.is_pushing and !player.is_pushing:
		if !ai.is_looking_down and !ai.is_looking_up:
			# Use a simple frame counter — you could track this as a var
			if Engine.get_physics_frames() % 64 == 0:
				force_jump()

func check_if_any_inputs_pressed():
	return (
		Input.is_action_pressed("player_a") or
		Input.is_action_pressed("player_b") or
		Input.is_action_pressed("player_c") or 
		Input.is_action_pressed("player_down") or
		Input.is_action_pressed("player_left") or
		Input.is_action_pressed("player_right") or
		Input.is_action_pressed("player_up")
	)

func get_random_jump_height():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return (rng.randf_range(ai.current_stats.min_jump_height + 60, ai.current_stats.max_jump_height))

func handle_flying_request_input():
	if state == 3:
		return
	
	if (
		Input.is_action_pressed("player_up") and
		Input.is_action_just_pressed("player_a") and 
		ai.is_rolling and
		!ai.__is_grounded and
		ai.velocity.y > -200 and
		ai.can_fly
	):
		state = 3
		ai.being_hanged_onto = true
		ai.change_state("Flying")
		
func handle_hanging_on_notifier():
	player.being_hanged_onto = ai.state_machine.current_state == "Hanging" and ai.hanging_object == player

func handle_limits():
	if (ai.limit_right != player.limit_right) and (ai.limit_left != player.limit_left):
		ai.lock_to_limits(player.limit_left, player.limit_right)
		

func _physics_process(_delta) -> void:
	
	if Input.is_action_just_pressed("player_debug"):
		enter_panic_spindash()
	
	if ai and player:
		handle_wall_push_jump()
		handle_flying_request_input()
		handle_limits()
		handle_hanging_on_notifier()
		#var distance = ai.global_position.distance_to(player.global_position)
		#print(distance)
		match state:
			0: handle_away_from_player_state()
			1: handle_close_to_player_state()
			2: handle_panic_spindash()
			3: handle_flying()
	elif !player and zone:
		player = zone.player
