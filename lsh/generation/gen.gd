extends Node2D

@export var dungeon_length:int = 3

var room_library

func _ready() -> void:
	randomize()
	room_library = DirAccess.open("res://generation/rooms/")
	for i in dungeon_length:
		pass

var last_generated_room
var shit

func append_room_to(room_arg = null):
	
	var room
	if room:
		pass
	elif !room:
		room = room_library.deep_copy().shuffle()[0]
	if last_generated_room:
		if are_rooms_compatible(last_generated_room, room):
			room.global_position = last_generated_room.global_position
			room.realign_to()
			add_child(room)
		else:
			pass

func are_rooms_compatible(rooma, roomb):
	rooma.connectors.shuffle()
	roomb.connectors.shuffle()
	for cona in rooma.connectors:
		for conb in roomb.connectors:
			if are_connectors_compatible(cona, conb):
				return true


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
