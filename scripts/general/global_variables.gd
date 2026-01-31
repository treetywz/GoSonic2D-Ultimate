extends Node2D

var control_lock : bool
var sonic_sprite : int
var character : int
var ring_drop = false
var chaos_emeralds = 7 # How many chaos emeralds the player has

var current_act = 1

const max_chaos_emeralds = 7 # Chaos Emerald cap
const ch_emerald_super_requirement = 7 # How many is needed to transform into Super Sonic?

func add_chaos_emerald():
	chaos_emeralds += 1
	if chaos_emeralds > max_chaos_emeralds:
		chaos_emeralds = max_chaos_emeralds
		
func find_zone_from_root():
	if not get_tree():
		return null
	if not get_tree().root:
		return null
	for i in get_tree().root.get_children():
		if i is Zone:
			return i
	return null
