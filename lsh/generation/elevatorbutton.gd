extends StaticBody2D

func interact():
	$AudioStreamPlayer2D.volume_db = randi_range(-2, 2)
	$AudioStreamPlayer2D.play()
	
	get_parent().toggle_door()
	if Utils.KEYLEVEL > Utils.FLOORLEVEL:
		get_parent().close_door()
		Utils.load_level(Utils.FLOORLEVEL)
