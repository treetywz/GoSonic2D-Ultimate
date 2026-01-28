extends ColorRect

var colors: Array = [
	Color("#a176db"),
	Color("#5a8de9"),
	Color("#bf7596")
]

@export var transition_time: float = 2.0

var current_index: int = 0
var next_index: int = 1
var time: float = 0.0

func _ready():
	color = colors[0]

func _process(delta):
	time += delta
	var progress = time / transition_time
	
	color = colors[current_index].lerp(colors[next_index], progress)
	
	if time >= transition_time:
		time = 0.0
		current_index = next_index
		next_index = (next_index + 1) % colors.size()
