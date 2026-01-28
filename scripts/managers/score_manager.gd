extends Node

var score = 0
var rings = 0
var lifes = 3

var time : float
var time_stoped: bool
var time_stopped_goal: bool

signal ring_added
signal score_added
signal life_added
signal time_over

const TIME_LIMIT = 600

var cap_rings = true

var lifes_added = 1
var lifes_added_score = 1
var life_for_every = 100
var life_for_every_score = 50000

var times_hit : int

func _process(delta):
	handle_time(delta)

func handle_time(delta: float):
	if not time_stoped and !time_stopped_goal:
		var next_time = time + delta
		if (next_time < TIME_LIMIT):
			time += delta
		else:
			time_stoped = true
			emit_signal("time_over")

func add_score(amount = 1):
	if amount > 0:
		score += amount
		emit_signal("score_added", score)

func remove_ring(amount):
	rings -= amount
	if rings < 0:
		rings = 0
	emit_signal("ring_added", rings)

func add_ring(amount = 1):
	if amount > 0:
		if cap_rings == true:
			if rings < 999:
				if amount >= 999:
					rings += 999
				else:
					rings += amount
			if rings > 999:
				rings = 999
		else:
			rings += amount
		emit_signal("ring_added", rings)

func add_life(amount = 1):
	if amount > 0:
		lifes += amount
		MusicManager.extra_life_jingle()
		emit_signal("life_added", lifes)
		
func extra_life(_player):
	if rings >= (lifes_added*life_for_every):
		add_life(1)
		lifes_added += 1
	if score >= (lifes_added_score*life_for_every_score):
		add_life(1)
		lifes_added_score += 1

func reset_score(_reset_score, reset_time, reset_rings):
	if _reset_score:
		score = 0
	if reset_rings:
		rings = 0
	if reset_time:
		time = 0
	lifes_added = 1
	
func time_limit_over():
	if time_stoped == true:
		return true
	else:
		return false
		
func stop_time_goal():
	time_stopped_goal = true
