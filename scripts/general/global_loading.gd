extends Node
@onready var loading_scene = preload("res://scenes/loading.tscn")

func load_scene(current_scene, next_scene):
	current_scene.queue_free()
	FadeManager.reset()
	ScoreManager.reset_score(false, false, true)
	
	# add loading scene to the root
	var loading_scene_instance = loading_scene.instantiate()
	get_tree().get_root().call_deferred("add_child", loading_scene_instance)
	
	# start threaded loading of the targeted scene
	var error = ResourceLoader.load_threaded_request(next_scene)
	
	# check for errors
	if error != OK:
		print("error occurred while requesting the scene: ", error)
		return
	
	# creating a little delay, that lets the loading screen to appear.
	await get_tree().create_timer(0.5).timeout
	
	# loading the next_scene using get_threaded_load_status() function
	while true:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(next_scene, progress)
		
		# while loading is in progress
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# update the progress bar according to amount of data loaded
			# progress[0] contains a value between 0.0 and 1.0
			pass
		
		# when loading is complete
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			# get the loaded resource
			var scene_resource = ResourceLoader.load_threaded_get(next_scene)
			# creating scene instance from loaded data
			var scene = scene_resource.instantiate()
			
			# removing existing skin if present
			var skin = get_tree().get_root().get_node_or_null("Skin")
			if skin:
				skin.call_deferred("free")
			
			MusicManager.replay_music()
			MusicManager.reset_volume()
			
			# adding scene to the root
			get_tree().get_root().call_deferred("add_child", scene)
			
			# removing loading scene
			loading_scene_instance.queue_free()
			FadeManager.prefadeout()
			return
		
		# handle loading errors
		else:
			print('error occurred while loading the scene, status: ', status)
			return
		
		# wait a frame before checking again
		await get_tree().process_frame

# Loading screen script adapted from: https://www.youtube.com/watch?v=5aV_GSAE1kM
