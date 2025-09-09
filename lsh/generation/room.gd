@tool

extends Node2D
class_name Room

var connectors
@onready var bounding_collision = $Bounds
@onready var connector_holder = $Connectors
var bounds:Vector2
var bounds_offset:Vector2

func _ready() -> void:
	update_preview(true)

@export var update_data:bool = false:
	set = update_preview

func update_preview(new_value):
	update_data = false
	connectors = []
	bounds = bounding_collision.shape.size
	bounds_offset = bounding_collision.position
	for child in connector_holder.get_children():
		if child.is_in_group("connector"):
			connectors.append(child)

func realign_to(connector):
	global_position -= connector.position

func get_realignment_vector(connector):
	return -connector.position
