extends Node
var save_directory = "user://godata.bin"

func save_file():
	return
	var data = {
		"score" : ScoreManager.score,
		"lifes" : ScoreManager.lifes,
		"lifes_added_score" : ScoreManager.lifes_added_score,
		"lifes_added" : ScoreManager.lifes_added
	}
	
	var f = FileAccess.open_encrypted_with_pass(save_directory, FileAccess.WRITE, "11242010")
	
	if f != null:
		f.store_var(data)
		f.close()
	else:
		print("Error saving file: ", FileAccess.get_open_error())

func load_file():
	return
	if FileAccess.file_exists(save_directory):
		var f = FileAccess.open_encrypted_with_pass(save_directory, FileAccess.READ, "11242010")
		
		if f != null:
			var player_data = f.get_var()
			ScoreManager.score = player_data.score
			ScoreManager.lifes = player_data.lifes
			ScoreManager.lifes_added_score = player_data.lifes_added_score
			ScoreManager.lifes_added = player_data.lifes_added
			
			f.close()
		else:
			print("Error loading file: ", FileAccess.get_open_error())
