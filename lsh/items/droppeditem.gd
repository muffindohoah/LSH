extends Node2D

@export var item_reference:Item
@export var is_random:bool

func _ready() -> void:
	if is_random:
		item_reference = Loot.get_lootation()
		print(item_reference.name)
		print(Loot.get_lootation())
	$Sprite2D.texture = item_reference.dropped_texture

func interact():
	if !Utils.PLAYER.held_item:
		Utils.PLAYER.pick_up(item_reference)
		queue_free()
