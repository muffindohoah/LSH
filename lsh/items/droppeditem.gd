extends Node2D

@export var item_reference:Item

func _ready() -> void:
	$Sprite2D.texture = item_reference.dropped_texture

func interact():
	if !Utils.PLAYER.held_item:
		Utils.PLAYER.pick_up(item_reference)
		queue_free()
