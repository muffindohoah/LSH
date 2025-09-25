extends Node

var GUI
var PLAYER
var GENERATION
var ELEVATOR

var KEYLEVEL = 10
var FLOORLEVEL = 1
var HELDITEM:Item

func load_level(lvlnumber):
	GENERATION.wipe_map()
	GENERATION.dungeon_length = ((lvlnumber * 5) + 20)
	GENERATION.generate()
	FLOORLEVEL = lvlnumber

signal PISSALERT(position)
signal GENERATIONCOMPLETE()
