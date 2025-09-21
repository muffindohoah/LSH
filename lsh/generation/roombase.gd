@icon("res://generation/roomicon.png")
@tool

class_name Room extends Area2D

@export var update_data: bool = false:
	set = update_preview

@export var room_name = "test room"

@export var bounds : Vector2
@export var bounds_offset : Vector2
@export var connectors : Array = []
@export var connector_distances : Dictionary = {}

func _ready() -> void:
	connect("body_entered", conflicting_door_entered)
	update_preview(true)

func conflicting_door_entered(body):
	if body is Door:
		body.queue_free()

func update_preview(new_value) -> void:
	update_data = false
	connectors = []
	bounds = $Bounds.shape.size
	bounds_offset = $Bounds.position
	for child in $Connectors.get_children():
		if child.is_in_group("connector"):
			connector_distances[child] = child.position
			connectors.append(child)
	return

func realign_to(connector) -> void:
	print("realigning...")
	self.global_position -= connector.position
	#self.global_position -= connector_distances[connector]
	return

#some bullshit2
func get_realignment_vector(connector):
	return connector_distances[connector]
