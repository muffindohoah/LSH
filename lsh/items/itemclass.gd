extends Resource
class_name Item

enum rarities {Common, Uncommon, Rare, Unique}

@export var name = "Item"
@export var inventory_texture:Texture = PlaceholderTexture2D.new()
@export var dropped_texture:Texture = PlaceholderTexture2D.new()
@export var can_be_used:bool = true
@export var use_scene:PackedScene
@export var rarity:rarities
