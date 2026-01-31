extends CanvasLayer

@onready var tally = $ScoreTally
@onready var fade_anim = $Fade/AnimationPlayer
@onready var titlecard = $TitleCard

func _ready():
	LoadingScreen.reload_call.connect(_reload_all_ui)
	tally.visible = false
	_reload_all_ui()

func enter_titlecard(zname):
	titlecard.enter_title_card(zname)
	
func exit_titlecard():
	titlecard.exit_title_card()

func _reload_all_ui():
	var to_reload = ["HUD", "Debug", "MobileControls"]
	var zone_exists = Global.find_zone_from_root() != null
	print("Reloading all UI...")
	
	for i in get_children():
		if i.name in to_reload:
			if zone_exists:
				i._enable()
			else:
				i._disable()
func fade_in():
	if !fade_anim.current_animation == "fade_in":
		fade_anim.play("fade_in")
	
func fade_out():
	if !fade_anim.current_animation == "fade_out":
		fade_anim.play("fade_out")
		
func black_screen():
	fade_anim.play("RESET")
	
func enter_tally(player_id, act_number):
	tally.setup_tally()
	tally.set_act_number(act_number)
	tally.set_player_name(player_id)
	tally.anim.play("enter")
	tally.visible = true

func tally_total():
	tally.tally_total()

func is_tallying():
	return tally.tallying
	
func exit_tally():
	tally.anim.play("exit")
