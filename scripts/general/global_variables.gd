extends Node2D

var control_lock : bool
var sonic_sprite : int
var character : int
var ring_drop = false
var chaos_emeralds = 7 # How many chaos emeralds the player has

const max_chaos_emeralds = 7 # Chaos Emerald cap
const ch_emerald_super_requirement = 7 # How many is needed to transform into Super Sonic?

func add_chaos_emerald():
	chaos_emeralds += 1
	if chaos_emeralds > max_chaos_emeralds:
		chaos_emeralds = max_chaos_emeralds
