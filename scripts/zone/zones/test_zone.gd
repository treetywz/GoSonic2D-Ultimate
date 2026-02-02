extends Zone
# Example zone script

func _init():
	cutscenes[0] = ending_cutscene

func ending_cutscene():
	player.enable_artificial_input()
	set_player_limit_right(3412)
	player.change_state("Regular")
	player.artificial_move_player_right(true)
	while !player.skin.off_screen:
		await pause(0.01)

func start_titlecard():
	UI.enter_titlecard(zone_name)
	await pause(2.9)
	UI.exit_titlecard()

func custom_intro():
	# Custom intro function, complete with comments.
	if Global.current_act == 1: # We will only run this custom intro on act 1.
		player.enable_artificial_input() # Enable the player's artifical inputs
		set_player_limit_left(-500) # Set the player's limits a little bit off screen to the left
		set_player_global_x(-29.0) # Put the player a little off screen to the left
		UI.fade_out() # Fade out the black screen
		player.can_move = true # Turn on the player's ability to move
		player.gravity_affected = true # Allow the player to be affected by gravity
		await pause(2) # await pause() waits for an amount of seconds before moving on.
		player.artificial_move_player_right(true) # Make the player start moving right
		await pause(0.7)
		player.artificial_move_player_right(false) # Stop the player from moving right
		await pause(2)
		player.disable_artificial_input() # Give control back to the player
		lock_player_limits() # Lock the player's limits to the actual level's limits
		player.vulnerable = true
		_zone_music()
		start_titlecard()
	else:
		_initialize_zone_intros()
