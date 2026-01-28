extends CanvasLayer

@onready var child = $ScoreTally

func _ready():
	child.visible = false

func enter(player_id, act_number):
	child.setup_tally()
	child.set_act_number(act_number)
	child.set_player_name(player_id)
	child.anim.play("enter")
	child.visible = true

func tally_total():
	child.tally_total()

func is_tallying():
	return child.tallying
func exit():
	child.anim.play("exit")
