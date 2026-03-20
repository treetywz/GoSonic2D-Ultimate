extends Node2D

# This entire script is purely just to handle Tails's tails visually.
# It serves no mechanical purpose, so I'm genuinely baffled on how it needs this
# much logic just to work..

@export_enum("Smooth", "Original") var tails_rotation_mode: String = "Original"
@onready var rolling = $Tails/Rolling
@onready var ground = $Ground
@onready var tails = $Tails

func _process(_delta):
	if is_instance_valid(get_parent().player):
		var player : Player = get_parent().player
		var skin : PlayerSkin = get_parent()
		rolling.speed_scale = skin.animation_tree.get("parameters/speed/scale")
		rolling.speed_scale = clamp(rolling.speed_scale, 1, 1.7)
		
		if player.state_machine.current_state == "Dead":
			# If he's dead, why bother rendering his tails
			rolling.visible = false
			ground.visible = false
			return
		
		# This chunk handles his tails when he's on the ground/braking.
		ground.visible = (player.velocity == Vector2.ZERO and
							!player.state_machine.current_state == "SpinDash" and
							player.__is_grounded
						) or (player.state_machine.current_state == "Braking")
		ground.flip_h = player.skin.flip_h
		if player.state_machine.current_state != "Braking":
			ground.position.y = 7
			ground.position.x = 15 if player.skin.flip_h else -15
		else:
			ground.position.y = 5
			ground.position.x = 9 if player.skin.flip_h else -9
		
		# Spindash gets highest priority over the non-idle tails, 
		# since no matter if smooth or original,
		# his tails function exactly the same.
		if player.state_machine.current_state == "SpinDash":
			tails.rotation = 0.0
			scale.x = -1 if skin.flip_h else 1
			tails.position = Vector2(5.0, 11.0)
			rolling.animation = "default"
			rolling.scale = Vector2(1, 1)
			rolling.visible = player.is_rolling
			return

		if player.is_rolling and player.__is_grounded and player.state_machine.current_state != "SpinDash":
			tails.position = Vector2.ZERO
			scale.x = sign(player.velocity.x)
			if tails_rotation_mode == "Smooth":
				# This single line is essentially what handles his SMOOTH tails rotation on the ground..
				tails.rotation = deg_to_rad(player.ground_angle) if player.velocity.x >= 0 else deg_to_rad(-player.ground_angle)
		else:
			tails.position = Vector2.ZERO
			scale.x = 1
			if tails_rotation_mode == "Smooth":
				# This single line is essentially what handles his SMOOTH tails rotation in the air..
				tails.rotation = player.velocity.angle()
		
		# The original on the other hand..
		# It's my best attempt at recreating the 45 degree snap that the original
		# Sonic 2/3 used for rotating sprites..
		if tails_rotation_mode == "Original":
			var target_rotation = 0.0
			
			# Here, we determine whether or not we calculate the rotation using
			# the player's ground angle or velocity. Since his y velocity is always = 0
			# when he is on the ground, we use his ground angle instead.
			
			if player.__is_grounded:
				if player.velocity.x < 0:
					target_rotation = deg_to_rad(-player.ground_angle)
				else:
					target_rotation = deg_to_rad(player.ground_angle)
			else:
				target_rotation = player.velocity.angle()

			var snapped_deg = round(rad_to_deg(target_rotation) / 45.0) * 45.0

			var d = int(fmod(snapped_deg, 360.0))
			if d < 0:
				d += 360
				
			# All of the diagonal angles.. manually snapped to use
			# the original game's special 45 degree rotation sprites
			# of Tails's tails.
			
			if d == 315:
				rolling.animation = "45"
				tails.position = Vector2(4.0, 9.0)
				tails.scale = Vector2(1, 1)
				tails.rotation = 0.0
			elif d == 45:
				rolling.animation = "45"
				tails.position = Vector2(4.0, -9.0)
				tails.scale = Vector2(1, -1)
				tails.rotation = 0.0
			elif d == 135:
				rolling.animation = "45"
				tails.position = Vector2(-4.0, -9.0)
				tails.scale = Vector2(-1, -1)
				tails.rotation = 0.0
			elif d == 225:
				rolling.animation = "45"
				tails.position = Vector2(-4.0, 9.0)
				tails.scale = Vector2(-1, 1)
				tails.rotation = 0.0
			else:
				rolling.animation = "default"
				tails.scale = Vector2(1, 1)
				tails.rotation = deg_to_rad(float(d))
				tails.position = Vector2.ZERO
		else:
			# If it's a straight angle, then just snap the default tails sprite to that angle
			rolling.animation = "default"
			tails.scale = Vector2(1, 1)
			tails.position = Vector2.ZERO

		rolling.visible = player.is_rolling
