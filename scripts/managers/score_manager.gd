extends Node

var score = 0
var rings = 0
var lifes = 3
var time : float
var time_stopped: bool

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

var player : Player

func _physics_process(delta):
	handle_time(delta)

func handle_time(delta: float):
	if not time_stopped:
		var next_time = time + delta
		if next_time <= TIME_LIMIT:
			time = next_time
		else:
			time = TIME_LIMIT
			time_stopped = true
			emit_signal("time_over")

func add_score(amount = 1):
	if amount > 0:
		score += amount
		emit_signal("score_added", score)
		check_score_milestone()

func remove_ring(amount):
	if amount < 0:
		push_warning("remove_ring called with negative amount: ", amount)
		return
	
	rings -= amount
	if rings < 0:
		rings = 0
	emit_signal("ring_added", rings)

func add_ring(amount = 1):
	if amount <= 0:
		return
	
	rings += amount
	
	if cap_rings and rings > 999:
		rings = 999
	
	emit_signal("ring_added", rings)
	check_ring_milestone()

func add_life(amount = 1):
	if amount > 0:
		lifes += amount
		MusicManager.extra_life_jingle()
		emit_signal("life_added", lifes)

func check_ring_milestone():
	var ring_milestone = lifes_added * life_for_every
	while rings >= ring_milestone:
		add_life(1)
		lifes_added += 1
		ring_milestone = lifes_added * life_for_every

func check_score_milestone():
	var score_milestone = lifes_added_score * life_for_every_score
	while score >= score_milestone:
		add_life(1)
		lifes_added_score += 1
		score_milestone = lifes_added_score * life_for_every_score


func reset_score(_reset_score, reset_time, reset_rings):
	if _reset_score:
		score = 0
		lifes_added_score = 1
		emit_signal("score_added", score)
	
	if reset_rings:
		rings = 0
		lifes_added = 1
		emit_signal("ring_added", rings)
	
	if reset_time:
		time = 0
		time_stopped = false
	

func stop_time():
	time_stopped = true

func start_time():
	time_stopped = false

func reset_time_and_start():
	time = 0
	time_stopped = false
