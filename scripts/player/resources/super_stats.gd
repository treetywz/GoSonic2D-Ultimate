extends Resource

class_name SuperStats

@export var acceleration: float = 675
@export var deceleration: float = 360
@export var friction: float = 168.75
@export var slope_factor: float = 337.5
@export var top_speed: float = 36000
@export var dash_speed: float = 600
@export var min_speed_to_brake: float = 240

@export var min_speed_to_roll: float = 60
@export var unroll_speed: float = 30
@export var slope_roll_up: float = 281.25
@export var slope_roll_down: float = 1125
@export var roll_deceleration: float = 450
@export var roll_friction: float = 84.375

@export var air_acceleration: float = 1552.5
@export var gravity: float = 787.5
@export var max_jump_height: float = 28800
@export var min_jump_height: float = 240

@export var slide_angle: float = 45
@export var fall_angle: float = 80
@export var min_speed_to_fall: float = 150
@export var control_lock_duration: float = 0.5

@export var drpspd: float = 480
@export var drpmax: float = 720

@export var hurt_x_force: float = 120
@export var hurt_y_force: float = -240
@export var hurt_gravity_force: float = 11.25
