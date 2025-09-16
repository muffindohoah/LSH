class_name clock extends Area2D

@onready var bounding_collision = $Bounds
@onready var connector_holder = $Connectors

var connectors
var bounds: Vector2 = Vector2(4,4)
var bounds_offset: Vector2

func _ready() -> void:
	update_data()
	return

func update_data() -> void:
	connectors = []
	bounds = $Bounds.shape.size
	bounds_offset = $Bounds.position
	for child in $Connectors.get_children():
		if child.is_in_group("connector"):
			connectors.append(child)
	return

func realign_to(connector) -> void:
	position -= (connector.position)
	return

func get_realignment_vector(connector):
	return -connector.position
