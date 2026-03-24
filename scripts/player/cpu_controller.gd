extends Node2D
class_name CPUController

@onready var zone = Global.find_zone_from_root() as Zone
@onready var player : Player
@onready var cpu : Player = get_parent()

# 0 = away, 1 = close, 2 = panic, 3 = flying
var state = 0

# Panic spindash internal state
var panic_waiting_for_standstill := false
var panic_spindash_charge_timer := 0
var panic_spindash_release_timer := 0
var panic_spindashing := false

var force_pulling_cpu := false

const SPINDASH_CHARGE_INTERVAL := 16
const SPINDASH_RELEASE_INTERVAL := 64

# This CPU logic is loosely based off of the one at the Sonic Physics Guide,
# but it's not exactly 1:1, as I've made my own tweaks here and there.


func _ready() -> void:
	cpu.enable_cpu_input()
	cpu.invincible_but_hurtable = true
	cpu.can_break_monitors = false

# State Handlers

func handle_away_from_player_state():
	var distance = cpu.global_position.distance_to(player.global_position)

	if distance <= 64:
		state = 1
		return

	# If I'm stuck on a slope, I'm gonna go into panic spindash
	if cpu.is_control_locked and floor(cpu.velocity) == Vector2.ZERO:
		enter_panic_spindash()
		return

	handle_copy_inputs()
	handle_pull_toward_player()

func handle_close_to_player_state():
	var distance = cpu.global_position.distance_to(player.global_position)

	if distance > 64:
		state = 0
		return

	# If I'm stuck on a slope, I'm gonna go into panic spindash
	if cpu.is_control_locked and floor(cpu.velocity) == Vector2.ZERO:
		enter_panic_spindash()
		return

	handle_copy_inputs()
	handle_pull_toward_player()

func handle_panic_spindash():
	# Step 1: Wait until I've stopped moving
	if floor(cpu.velocity) != Vector2.ZERO:
		cpu.cpu_move_left  = false
		cpu.cpu_move_right = false
		cpu.cpu_look_up    = false
		cpu.cpu_look_down  = false
		cpu.cpu_jump         = false
		cpu.cpu_jump_release = false
		return

	# Step 2: Face the player
	var facing_player_left = player.global_position.x < cpu.global_position.x
	cpu.cpu_move_left  = facing_player_left
	cpu.cpu_move_right = !facing_player_left

	# Step 3: If I'm not yet spindashing, I'll crouch and prepare for spindash
	if !panic_spindashing:
		cpu.cpu_look_down = true
		await get_tree().create_timer(0.2).timeout
		panic_spindashing = true
		panic_spindash_charge_timer = 0
		panic_spindash_release_timer = 0
		return

	# Step 4: Charge the spindash every 32 frames
	panic_spindash_charge_timer += 1
	panic_spindash_release_timer += 1

	cpu.cpu_jump = (panic_spindash_charge_timer % SPINDASH_CHARGE_INTERVAL == 0)

	# Step 5: After 128 frames, I'll release the spindash and exit the panic spindash state
	if panic_spindash_release_timer >= SPINDASH_RELEASE_INTERVAL:
		cpu.cpu_look_down  = false
		cpu.cpu_jump_release = true
		cpu.clear_cpu_inputs()
		exit_panic_spindash()
		
func handle_flying():
	var x_distance = abs(player.global_position.x - cpu.global_position.x)
	cpu.being_hanged_onto = player.hanging_object == cpu
	
	if player.hanging_object == cpu:
		# If the player is hanging onto me, CPU input is overriden by player input
		cpu.cpu_move_left    = Input.is_action_pressed("player_left")
		cpu.cpu_move_right   = Input.is_action_pressed("player_right")
		cpu.cpu_look_up      = Input.is_action_pressed("player_up")
		cpu.cpu_look_down    = Input.is_action_pressed("player_down")
	elif !floor(x_distance) == 0:
		# If the player isn't hanging onto me, and I'm not near them..
		var cpu_is_left = cpu.global_position.x < player.global_position.x
		if cpu_is_left:
			# Move fly towards the player
			cpu.cpu_move_right = true
			cpu.cpu_move_left = false
		elif !cpu_is_left:
			# Move fly towards the player
			cpu.cpu_move_left = true
			cpu.cpu_move_right = false
			
	# No matter what, whenever I'm flying, the player overrides my action button.
	cpu.cpu_jump = Input.is_action_pressed("player_a")
	cpu.cpu_jump_release = Input.is_action_just_released("player_a")
	
	if cpu.__is_grounded:
		# The second I touch the ground, I'm back into state 1.
		state = 1

# Helpers

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
	cpu.cpu_jump_release = false

func force_jump():
	if cpu.__is_grounded:
		cpu.audios.jump_audio.play()
		cpu.is_rolling = true
		cpu.velocity.y = -get_random_jump_height()

func handle_copy_inputs():
	if !force_pulling_cpu:
		var frame = player.get_delayed_input()
		cpu.cpu_move_left    = frame.move_left
		cpu.cpu_move_right   = frame.move_right
		cpu.cpu_look_up      = frame.look_up
		cpu.cpu_look_down    = frame.look_down
		cpu.cpu_jump         = frame.jump_pressed
		cpu.cpu_jump_release = frame.jump_released

func handle_pull_toward_player():
	var distance = cpu.global_position.distance_to(player.global_position)
	var x_distance = abs(player.global_position.x - cpu.global_position.x)
	if ( # Ignore the pull towards if the player has inputs pressed/I'm near the player
		((check_if_any_inputs_pressed() or
		distance < 20 or
		floor(x_distance) == 0)) and 
		# But if I am 200 pixels away from the player, it will override the checks above
		distance < 200
		):
		
		force_pulling_cpu = false
		
		return
		
	elif distance > 256:
		# If I am 256 pixels away from the player, no matter what, I am forced to get pulled.
		force_pulling_cpu = true

	var cpu_is_left = cpu.global_position.x < player.global_position.x

	if cpu_is_left:
		# If I am to the left of the player, I will get pulled right
		cpu.cpu_move_right = true
		cpu.cpu_move_left = false
	elif !cpu_is_left:
		# Vice versa
		cpu.cpu_move_left = true
		cpu.cpu_move_right = false
		
	if cpu.velocity == Vector2.ZERO:
		if Engine.get_physics_frames() % 64 == 0:
			force_jump()

func handle_wall_push_jump():
	# If I am pushing a wall, and the player isn't, I will try to jump out
	if cpu.is_pushing and !player.is_pushing:
		if !cpu.is_looking_down and !cpu.is_looking_up:
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
	return (rng.randf_range(cpu.current_stats.min_jump_height + 60, cpu.current_stats.max_jump_height))

func handle_flying_request_input():
	if state == 3:
		return
	
	if ( # If the player presses Up + Action Button while I am in the air falling while rolling,
		# and I am able to fly, I will fly.
		Input.is_action_pressed("player_up") and
		Input.is_action_just_pressed("player_a") and 
		cpu.is_rolling and
		!cpu.__is_grounded and
		cpu.velocity.y > -200 and
		cpu.can_fly
	):
		state = 3
		cpu.change_state("Flying")
		
func handle_hanging_on_notifier():
	# Let the player know if they are being hung onto by me
	player.being_hanged_onto = cpu.state_machine.current_state == "Hanging" and cpu.hanging_object == player

func handle_limits():
	if (cpu.limit_right != player.limit_right) or (cpu.limit_left != player.limit_left):
		# Lock to the player's limits if limit_left or limit_right aren't the same
		cpu.lock_to_limits(player.limit_left, player.limit_right)
		

func _physics_process(_delta) -> void:
	if cpu and player:
		handle_wall_push_jump()
		handle_flying_request_input()
		handle_limits()
		handle_hanging_on_notifier()
		match state:
			0: handle_away_from_player_state()
			1: handle_close_to_player_state()
			2: handle_panic_spindash()
			3: handle_flying()
	elif !player and zone:
		# If I do not have an assigned player, I will assign myself the zone's player and
		# also teleport to the player immediately.
		player = zone.player
		var x_offset = 19
		var x_multipler = 1 if player.skin.flip_h else -1
		cpu.global_position = player.global_position + Vector2(x_offset * x_multipler, 0)
