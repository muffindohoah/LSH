extends Node2D

@export var dungeon_length:int = 3

var room_library

func _ready() -> void:
	randomize()
	room_library = dir_contents("res://generation/rooms/")
	generate_dungeon()

var last_generated_room

func generate_dungeon():
	for i in dungeon_length:
		append_room_to()

func append_room_to(room_arg = null):
	var room
	if room:
		pass
	elif !room:
		room_library.shuffle()
		room = room_library[0]
	room = room.instantiate()
	room.update_preview(true)
	if last_generated_room:
		print(last_generated_room, are_rooms_compatible(last_generated_room, room))
		if are_rooms_compatible(last_generated_room, room):
			room.global_position = last_generated_room.global_position
			room.realign_to()
			add_child(room)
			last_generated_room = room
	else:
		print("gorn")
		add_child(room)
		last_generated_room = room

func are_rooms_compatible(rooma, roomb):
	rooma.connectors.shuffle()
	roomb.connectors.shuffle()
	for cona in rooma.connectors:
		for conb in roomb.connectors:
			if are_connectors_compatible(cona, conb):
				return true
	return false

func are_connectors_compatible(cona, conb):
	var result
	
	if cona.left == true:
		if conb.right == true:
			result = true
	
	if cona.right == true:
		if conb.left == true:
			result = true
	
	if cona.up == true:
		if conb.down == true:
			result = true
	
	if cona.down == true:
		if conb.up == true:
			result = true
	
	return result

func dir_contents(path):
	var scene_loads = []	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if file_name.get_extension() == "tscn":
					var full_path = path.path_join(file_name)
					scene_loads.append(load(full_path))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	return scene_loads
