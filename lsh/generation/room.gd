extends Node2D

var connectors
var bounds:Vector2
var bounds_offset:Vector2

func _ready() -> void:
	update_preview(true)

@export var update_data:bool = false:
	set = update_preview

func update_preview(new_value):
	update_data = false
	connectors = []
	bounds = $Bounds.shape.size
	bounds_offset = $Bounds.position
	for child in $Connectors.get_children():
		if child.is_in_group("connector"):
			connectors.append(child)

func realign_to(connector):
	global_position -= connector.position

func get_realignment_vector(connector):
	return -connector.position
