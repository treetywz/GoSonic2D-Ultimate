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
	
	# Get the acts array and current act number
	var acts = zone.get("acts")
	var act_number = zone.get("act_number") if zone.get("act_number") != null else 1
	
	if !acts or acts.is_empty():
		return
	
	# Get the current act's limits (act_number is 1-based, array is 0-based)
	var act_index = act_number - 1
	if act_index < 0 or act_index >= acts.size():
		act_index = 0  # Default to first act if invalid
	
	var current_act = acts[act_index]
	if !current_act:
		return
	
	# Get limit values from the current act
	var limit_left = current_act.get("limit_left") if current_act.get("limit_left") != null else 0
	var limit_right = current_act.get("limit_right") if current_act.get("limit_right") != null else 10000
	var limit_top = current_act.get("limit_top") if current_act.get("limit_top") != null else 0
	var limit_bottom = current_act.get("limit_bottom") if current_act.get("limit_bottom") != null else 10000
	
	var limit_color = Color(1, 0.2, 0.2, 1)
	var limit_width = 3.0
	
	# Draw the four limit lines
	draw_line(Vector2(limit_left, limit_top), Vector2(limit_left, limit_bottom), limit_color, limit_width)
	draw_line(Vector2(limit_right, limit_top), Vector2(limit_right, limit_bottom), limit_color, limit_width)
	draw_line(Vector2(limit_left, limit_top), Vector2(limit_right, limit_top), limit_color, limit_width)
	draw_line(Vector2(limit_left, limit_bottom), Vector2(limit_right, limit_bottom), limit_color, limit_width)
