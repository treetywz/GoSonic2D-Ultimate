@tool
extends Node2D

@export var path_segments: int = 64:
	set(value):
		path_segments = max(8, value)
		queue_redraw()

@export var path_color: Color = Color(1, 1, 0, 0.8):
	set(value):
		path_color = value
		queue_redraw()

@export var path_width: float = 2.0:
	set(value):
		path_width = value
		queue_redraw()

@export var show_start_end_markers: bool = true:
	set(value):
		show_start_end_markers = value
		queue_redraw()

var platform: MovingPlatform

func _ready():
	if Engine.is_editor_hint():
		platform = get_parent() as MovingPlatform
		if platform:
			# Connect to parent's property changes if possible
			set_notify_transform(true)
	else:
		# Hide in-game
		visible = false

func _process(_delta):
	if Engine.is_editor_hint():
		# Redraw if parent properties might have changed
		queue_redraw()

func _draw():
	if not Engine.is_editor_hint():
		return
	
	platform = get_parent() as MovingPlatform
	if not platform:
		return
	
	var points: PackedVector2Array = []
	
	# Generate path points based on parent's movement type
	for i in range(path_segments + 1):
		var t = (float(i) / path_segments) * TAU
		var point = Vector2.ZERO
		
		if platform.movement_type == "Vertical":
			point.y = platform.amplitude * sin(platform.period * t)
		elif platform.movement_type == "Horizontal":
			point.x = platform.amplitude * cos(platform.period * t)
		else:  # Circular
			point.x = platform.amplitude * cos(platform.period * t)
			point.y = platform.amplitude * sin(platform.period * t)
		
		points.append(point)
	
	# Draw the path
	if points.size() > 1:
		for i in range(points.size() - 1):
			draw_line(points[i], points[i + 1], path_color, path_width)
		
		# Connect last point to first for circular paths
		if platform.movement_type == "Circular":
			draw_line(points[points.size() - 1], points[0], path_color, path_width)
	
	# Draw start and end markers
	if show_start_end_markers:
		draw_circle(points[0], 4, Color(0, 1, 0, 0.8))  # Green for start
		if platform.movement_type != "Circular":
			draw_circle(points[points.size() - 1], 4, Color(1, 0, 0, 0.8))  # Red for end
