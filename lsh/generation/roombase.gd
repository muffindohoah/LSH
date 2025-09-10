@icon("res://generation/roomicon.png")
@tool
extends Area2D
class_name Room

@export var update_data: bool = false:
	set = update_preview

@export var room_name = "test room"

@export var bounds : Vector2
@export var bounds_offset : Vector2
@export var connectors : Array = []
@export var connector_distances : Dictionary = {}

func _ready() -> void:
	update_preview(true)

func update_preview(new_value):
	update_data = false
	connectors = []
	bounds = $Bounds.shape.size
	bounds_offset = $Bounds.position
	for child in $Connectors.get_children():
		if child.is_in_group("connector"):
			connector_distances[child] = child.position
			
			connectors.append(child)

func realign_to(connector):
	print("realigning...")
	self.global_position -= connector.position
	#self.global_position -= connector_distances[connector]

#some bullshit2
func get_realignment_vector(connector):
	return connector_distances[connector]
