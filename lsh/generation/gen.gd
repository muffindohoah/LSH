extends Node2D

@onready var room_scenes = [] #this will automatially append from */rooms
@onready var completed_rooms = []
@onready var roomcoll_area: Area2D = $Area2D

@export var dungeon_length: int = 3

@export_category("Sidequests")
@export var sidequest_length: int = 3
@export var sidequest: SideQuest

var last_generated_room: Room = null

const _does_room_fit__timeout: float = 0.03

func _init() -> void:
	Utils.GENERATION = self

func _ready() -> void:
	# TODO: Not sure if any of this is necessary. randomize is ran on project start, and seeds aren't useful without a seed input
		# this will be called several times as we regenerate the level. seeds are 'good practice'. its unneccessary though yeah.
	randomize()
	var random_seed: int = randi()
	$Label.text = "Seed: " + str(random_seed)
	seed(random_seed)
	
	if sidequest:
		sidequest_length = sidequest.quest_length
	
	room_scenes = dir_contents("res://generation/rooms/")
	room_scenes.shuffle()
	Utils.load_level(Utils.FLOORLEVEL)


func wipe_map():
	for room in completed_rooms:
		if !room.is_in_group("elevator"):
			completed_rooms.erase(room)
			room.queue_free()
		else:
			last_generated_room = room

func generate():
	randomize()
	#this will create the main snake. at the end we will place the objective.
	for i in range(dungeon_length):
		if i == 0 && last_generated_room == null:
			append_room_to(last_generated_room, load("res://generation/elevator.tscn").instantiate())
		elif i == 0:
			get_tree().reload_current_scene()
			return
		
		if await append_room_to(last_generated_room):
			pass
		else:
			print("deadend. realign snake")
			last_generated_room = completed_rooms.pick_random()
	
	
	#create random shit to make the map feel natural. this does not have to make logical sense.
	for i in completed_rooms.size():
		await append_room_to(completed_rooms.pick_random())
	
	#fill gaps
	var completed_rooms_duplicate = completed_rooms.duplicate(true)
	for completed_room in completed_rooms_duplicate:
		for connector in completed_room.connectors:
			if !connector.taken:
				if connector.left or connector.right:
					#append_room_to(completed_room, load("res://generation/blockoffs/blockoffhoriz.tscn").instantiate())
					pass
				elif connector.up or connector.down:
					pass
					#append_room_to(completed_room, load("res://generation/blockoffs/blockoffvert.tscn").instantiate())
	
	#this will create the 'sidequest'. this will not be used. no time. 
	if sidequest_length > 0:
		print("questing...")
		
		#shuffle, then pick a random room to start branching path.
		# TODO: Does this need to be a deep dupe or can it be shallow? More importantly, does it
			# really matter the order in which the rooms in "completed_rooms" sit? If not, there's
			# no point in doing a duplication 
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
	Utils.GENERATIONCOMPLETE.emit()
	print("that's a wrap.")


func append_room_to(room: Room = null, rscn_to_be_added = null) -> bool:
	#if there is a custom rscn, try to append that. if there is not, use random.
	var potential_room: Room
	
	if rscn_to_be_added != null:
		potential_room  = rscn_to_be_added
		print("custom room:", rscn_to_be_added)
	else:
		potential_room = room_scenes[randi_range(0, room_scenes.size()-1)].instantiate()
	# TODO: Style/Readibility note: It's generally easier to read code that only switches in case
	# a condition is satisified. So instead of testing for null and doing the default thing, check
	# for not null and do the special thing, then do the default thing
	
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
	var open_doorways: Array = room.connectors
	var potential_doorways: Array = potential_room.connectors
	
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
				#if all else fails...
	#bless up
	
	# TODO: Should this return true?
	return false


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


func does_room_fit(room: Room, connector: Connector, ref_connector):
	var offset: Vector2 = room.bounds_offset
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

	await get_tree().create_timer(_does_room_fit__timeout).timeout
	
	if has_overlapping_rooms(roomcoll_area, connector.get_parent().get_parent()):
		return false
	return true


#i hate this. it will have to do.
# made it nicer for you
func are_connectors_compatible(con_a: Connector, con_b: Connector):
	var result: bool = false
	
	if  (con_a.left && con_b.right) || \
		(con_a.right && con_b.left) || \
		(con_a.up && con_b.down) || \
		(con_a.down && con_b.up):
			for category in con_a.categories:
				if con_b.categories.has(category):
					result = true
	
	return result


#returns scenes in directory
func dir_contents(path: String):
	var scene_loads: Array = []
	var dir: DirAccess = DirAccess.open(path)
	
	if !dir:
		print("An error occurred when trying to access the path.")
		return null

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			print("Found directory: " + file_name)
			
		else:
			if file_name.get_extension() == "tscn":
				var full_path = path.path_join(file_name)
				scene_loads.append(load(full_path))
		
		file_name = dir.get_next()
	
	return scene_loads
