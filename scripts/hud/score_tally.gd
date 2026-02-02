extends Control

# Constants
const TALLY_INTERVAL = 0.02
const TALLY_INCREMENT = 100
const MAX_HIT_PENALTY = 10

# Time bonus thresholds (Sonic 3 System)
const TIME_BONUS_PERFECT = 100000  # 9:59
const TIME_BONUS_FAST = 50000      # 0:00-0:59
const TIME_BONUS_GOOD = 10000      # 1:00-1:29
const TIME_BONUS_DECENT = 5000     # 1:30-1:59
const TIME_BONUS_OK = 4000         # 2:00-2:29
const TIME_BONUS_AVERAGE = 3000    # 2:30-2:59
const TIME_BONUS_SLOW = 1000       # 3:00-3:29
const TIME_BONUS_VERYSLOW = 100    # 3:30-9:58

# Cool bonus point table (indexed by times hit, clamped to 10)
const COOL_BONUS_TABLE = [10000, 9000, 8000, 7000, 6000, 5000, 4000, 3000, 2000, 1000, 0]

# Character marker frames
const MARKER_FRAMES = {
	"Sonic": 0,
	"Tails": 1,
	"Knuckles": 2
}

# Node References
@onready var ring_bonus_label = $RingBonuss/Label
@onready var time_bonus_label = $TimeBouns/Label
@onready var cool_bonus_label = $CoolBonus/Label
@onready var total_label = $Total/Label
@onready var anim = $AnimationPlayer
@onready var player_name = $Player
@onready var count_audio = $count
@onready var total_audio = $totalsound
@onready var act_texture = $Through/Act

# Marker references (cached)
@onready var time_marker = $TimeBouns/Marker
@onready var cool_marker = $CoolBonus/Marker
@onready var ring_marker = $RingBonuss/Marker
@onready var total_marker = $Total/Marker

# Character textures
@export_group("Character Textures")
@export var sonic_name: Texture2D
@export var tails_name: Texture2D
@export var knuckles_name: Texture2D

# Act textures
@export_group("Act Textures")
@export var act_1: Texture2D
@export var act_2: Texture2D

# Tally state
var ring_bonus: int = 0
var time_bonus: int = 0
var cool_bonus: int = 0
var total: int = 0
var tallying: bool = false
var pressed_mob = false


func _disable():
	visible = false
	tallying = false
	
func _enable():
	visible = true
	anim.play("no")

func _process(_delta):
	_update_labels()


func _update_labels():
	ring_bonus_label.text = str(ring_bonus)
	time_bonus_label.text = str(time_bonus)
	cool_bonus_label.text = str(cool_bonus)
	total_label.text = str(total)


func setup_tally():
	ring_bonus = _calculate_ring_bonus()
	time_bonus = _calculate_time_bonus()
	cool_bonus = _calculate_cool_bonus()
	total = 0

func _input(event):
	if event.is_pressed() and event is InputEventScreenTouch:
		if tallying:
			pressed_mob = true

func tally_total():
	tallying = true
	
	while ring_bonus > 0 or time_bonus > 0 or cool_bonus > 0:
		if Input.is_action_just_pressed("player_a") or pressed_mob:
			pressed_mob = false
			# Add all remaining bonuses immediately
			total += ring_bonus + time_bonus + cool_bonus
			ScoreManager.add_score(ring_bonus + time_bonus + cool_bonus)
			ring_bonus = 0
			time_bonus = 0
			cool_bonus = 0
			break
		
		if !tallying:
			break
		
		await get_tree().create_timer(TALLY_INTERVAL).timeout
		
		var added_this_frame = 0
		
		if ring_bonus > 0:
			var amount = min(ring_bonus, TALLY_INCREMENT)
			ring_bonus -= amount
			added_this_frame += amount
		
		if time_bonus > 0:
			var amount = min(time_bonus, TALLY_INCREMENT)
			time_bonus -= amount
			added_this_frame += amount
		
		if cool_bonus > 0:
			var amount = min(cool_bonus, TALLY_INCREMENT)
			cool_bonus -= amount
			added_this_frame += amount
		
		if added_this_frame > 0:
			total += added_this_frame
			ScoreManager.add_score(added_this_frame)
			count_audio.play()
	
	total_audio.play()
	tallying = false


func _calculate_time_bonus() -> int:
	var time = int(ScoreManager.time)
	
	if time == 599:
		return TIME_BONUS_PERFECT
	elif time <= 59:
		return TIME_BONUS_FAST
	elif time <= 89:
		return TIME_BONUS_GOOD
	elif time <= 119:
		return TIME_BONUS_DECENT
	elif time <= 149:
		return TIME_BONUS_OK
	elif time <= 179:
		return TIME_BONUS_AVERAGE
	elif time <= 209:
		return TIME_BONUS_SLOW
	elif time <= 598:
		return TIME_BONUS_VERYSLOW
	else:
		return 0


func _calculate_ring_bonus() -> int:
	return ScoreManager.rings * 100


func _calculate_cool_bonus() -> int:
	if ScoreManager.has_died:
		return 0
	var times_hit = mini(ScoreManager.times_hit, MAX_HIT_PENALTY)
	return COOL_BONUS_TABLE[times_hit]


func set_player_name(player_id: String):
	# Set character texture
	var texture_map = {
		"Sonic": sonic_name,
		"Tails": tails_name,
		"Knuckles": knuckles_name
	}
	
	if player_id in texture_map:
		player_name.texture = texture_map[player_id]
	
	# Set marker frames
	if player_id in MARKER_FRAMES:
		var frame = MARKER_FRAMES[player_id]
		time_marker.frame = frame
		cool_marker.frame = frame
		ring_marker.frame = frame
		total_marker.frame = frame


func set_act_number(act: int):
	match act:
		1:
			act_texture.texture = act_1
		2:
			act_texture.texture = act_2
