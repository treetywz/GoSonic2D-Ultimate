extends Node

class_name ScoreController

@export var score: int
@export var rings: int
@export var lifes: int



@onready var score_manager = get_node("/root/ScoreManager") as ScoreManager

func add_score():
	score_manager.add_score(score)
	score_manager.add_ring(rings)
	score_manager.add_life(lifes)
