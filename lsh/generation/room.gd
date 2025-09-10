extends Area2D
class_name clock

@onready var bounding_collision = $Bounds
@onready var connector_holder = $Connectors

var connectors
var bounds:Vector2 = Vector2(4,4)
var bounds_offset:Vector2

func _ready() -> void:
	update_data()

func update_data():
	connectors = []
	bounds = $Bounds.shape.size
	bounds_offset = $Bounds.position
	for child in $Connectors.get_children():
		if child.is_in_group("connector"):
			connectors.append(child)

func realign_to(connector):
	position -= (connector.position)

func get_realignment_vector(connector):
	return -connector.position
