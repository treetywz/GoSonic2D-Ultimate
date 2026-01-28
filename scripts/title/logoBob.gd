extends TextureRect

@export var amplitude: float = 7  # How far up/down it moves
@export var speed: float = 0.9  # How fast it bobs

var time: float = 0.0
var initial_position: Vector2

func _ready():
	initial_position = position

func _process(delta):
	time += delta * speed
	position.y = initial_position.y + sin(time) * amplitude
