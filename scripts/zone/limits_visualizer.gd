@tool
extends Node2D

func _process(_delta):
	queue_redraw()

func _draw():
	if !Engine.is_editor_hint():
		return
	
	var zone = get_parent()
	if !zone:
		return
	
	# Get limit values with defaults
	var limit_left = zone.get("limit_left") if zone.get("limit_left") != null else 0
	var limit_right = zone.get("limit_right") if zone.get("limit_right") != null else 10000
	var limit_top = zone.get("limit_top") if zone.get("limit_top") != null else 0
	var limit_bottom = zone.get("limit_bottom") if zone.get("limit_bottom") != null else 10000
	
	var limit_color = Color(1, 0.2, 0.2, 1)
	var limit_width = 3.0
	
	# Draw the four limit lines
	draw_line(Vector2(limit_left, limit_top), Vector2(limit_left, limit_bottom), limit_color, limit_width)
	draw_line(Vector2(limit_right, limit_top), Vector2(limit_right, limit_bottom), limit_color, limit_width)
	draw_line(Vector2(limit_left, limit_top), Vector2(limit_right, limit_top), limit_color, limit_width)
	draw_line(Vector2(limit_left, limit_bottom), Vector2(limit_right, limit_bottom), limit_color, limit_width)
