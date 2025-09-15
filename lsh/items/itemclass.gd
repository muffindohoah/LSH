extends Resource
class_name Item

@export var name = "Item"
@export var inventory_texture:Texture = PlaceholderTexture2D.new()
@export var dropped_texture:Texture = PlaceholderTexture2D.new()
@export var use_scene:PackedScene
