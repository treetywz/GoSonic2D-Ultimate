extends StaticBody2D

class_name MovingPlatform

@export_enum("Vertical", "Horizontal", "Circular") var movement_type = "Vertical"
@export var amplitude: float = 50
@export var period: float = 1

@onready var center = position

var time: float

func _physics_process(delta):
	time += delta
	if movement_type != "Vertical":
		position.x = center.x + amplitude * cos(period * time)
	if movement_type != "Horizontal":
		position.y = center.y + amplitude * sin(period * time)
