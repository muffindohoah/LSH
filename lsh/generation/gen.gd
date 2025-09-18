extends Node2D

@onready var room_scenes = [] #this will automatially append from */rooms
@onready var completed_rooms = []
@onready var roomcoll_area: Area2D = $Area2D

# TODO: make this a constant asap
@export var dungeon_length: int = 3

@export_category("Sidequests")
@export var sidequest_length: int = 3
@export var sidequest: SideQuest

var last_generated_room = null


const _DOES_ROOM_FIT__TIMER_TIMEOUT_: float = 0.4

func _ready() -> void:
	# TODO: Not sure if any of this is necessary. randomize is ran on project start, and seeds aren't useful without a seed input
	randomize()
	var random_seed: int = randi()
	$Label.text = "Seed: " + str(random_seed)
	seed(random_seed)
	
	if sidequest:
		sidequest_length = sidequest.quest_length
	
	room_scenes = dir_contents("res://generation/rooms/")
	room_scenes.shuffle()
	generate()


func generate():
	
	#this will create the main snake
	for i in range(dungeon_length):
		if i == 0:
			append_room_to(last_generated_room, load("res://generation/rooms/elevator.tscn").instantiate())
		await append_room_to(last_generated_room)
	
	#this will create the 'sidequest'
	if sidequest_length > 0:
		print("questing...")
		
		#shuffle, then pick a random room to start branching path.
		var sidequest_branch_room = completed_rooms.duplicate_deep()
		sidequest_branch_room.shuffle()
		sidequest_branch_room = sidequest_branch_room[0]
		
		#make certain sidequest_branch_room is the last_generated_room, branch/bloom
		await append_room_to(sidequest_branch_room)
		for i in range(sidequest_length-1):
			await append_room_to(last_generated_room)
		
		#if sidequest is set correctly, spawn corresponding room.
		if sidequest:
			await append_room_to(last_generated_room, sidequest.quest_room)
	
	print("that's a wrap.")


func append_room_to(room = null, rscn_to_be_added = null) -> bool:
	#if there is a custom rscn, try to append that. if there is not, use random.
	var potential_room
	if rscn_to_be_added == null:
		potential_room = room_scenes[randi_range(0, room_scenes.size()-1)].instantiate()
	else:
		potential_room  = rscn_to_be_added
	
	print("onto the next..")
	
	#makes sure data is up to date for the room
	potential_room.update_preview(true)
	
	#spawn if no other room
	if room == null:
		add_child(potential_room)
		print("i must be the first!")
		completed_rooms.append(potential_room)
		last_generated_room = potential_room
		return true
	
	#kiss connectors
	var open_doorways = room.connectors
	var potential_doorways = potential_room.connectors
	
	#paths lol xd random
	potential_doorways.shuffle()
	open_doorways.shuffle()
	
	#check every open, and potential doorway for compatability. 
	for od in open_doorways.size():
		for pd in potential_doorways.size():
			$Debug.global_position = open_doorways[od].global_position
			$Debug2.global_position = potential_doorways[pd].global_position
			
			# TODO: Bro what is this
			if are_connectors_compatible(open_doorways[od], potential_doorways[pd]):
				if await kiss_connectors(room, potential_room, open_doorways[od], potential_doorways[pd]):
					print("done!")
					return true
				else:
					print("X")
			else:
				print("incompatible")
	#bless up
	
	# TODO: Should this return true?
	return true


#cant find better naming convention... now kith
func kiss_connectors(og_room, potential_room, og_connector, potential_connector) -> bool:
	if og_connector.taken || potential_connector.taken == true:
		print("taken!")
		return false
	
	#align collision detection correctly.
	if not await does_room_fit(potential_room, og_connector, potential_connector):
		print("dont fit!")
		return false
	
	#check if collision detection detects conflicting rooms. if not, spawn room.
	potential_room.global_position = og_connector.global_position
	potential_room.realign_to(potential_connector)
	
	og_connector.taken = true
	potential_connector.taken = true
	
	var final_potential_room = potential_room.duplicate()
	final_potential_room.global_position = potential_room.global_position
	last_generated_room = final_potential_room
	completed_rooms.append(final_potential_room)
	add_child(final_potential_room)
	#$Camera2D.position = final_potential_room.position
	return true


func has_overlapping_rooms(area:Area2D, exception) -> bool:
	area.force_update_transform()
	for i in area.get_overlapping_areas():
		if i == exception:
			print("Ran into exception: " + str(i))
			continue
			
		if i.is_in_group("room"):
			return true

	return false


func does_room_fit(room, connector, ref_connector):
	var offset = room.bounds_offset
	var roomcoll_shape = roomcoll_area.get_child(0)
	roomcoll_shape.shape.size = room.bounds
	
	#$Debug.position = connector.position
	#$Debug.global_position -= room.get_realignment_vector(ref_connector)
	
	roomcoll_area.global_position = connector.global_position
	roomcoll_area.global_position -= room.get_realignment_vector(ref_connector)
	roomcoll_area.global_position += offset
	
	# TODO: magic number
	var checking_offset = 3
	if ref_connector.up:
		roomcoll_area.global_position.y += checking_offset
		
	if ref_connector.down:
		roomcoll_area.global_position.y -= checking_offset
	if ref_connector.left:
		roomcoll_area.global_position.x += checking_offset
	if ref_connector.right:
		roomcoll_area.global_position.x -= checking_offset


	await get_tree().create_timer(_DOES_ROOM_FIT__TIMER_TIMEOUT_).timeout
	
	if has_overlapping_rooms(roomcoll_area, connector.get_parent().get_parent()):
		return false
	else:
		return true


#i hate this. it will have to do.
	# made it nicer for you
func are_connectors_compatible(con_a, con_b):
	var result: bool = false
	
	if (con_a.left && con_b.right) || \
		(con_a.right && con_b.left) || \
		(con_a.up && con_b.down) || \
		(con_a.down && con_b.up):
			result = true
	
	return result


#returns scenes in directory
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
