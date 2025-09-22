extends Resource

class_name Furniture

@export var name: String
@export var base_texture: Texture
@export var collision_vector: Vector2
@export var openable: bool
@export var opened_texture: Texture
@export var item_drop_pos:Vector2 = Vector2(0,0)
@export var emits_light: bool
@export var light_size: float = 0.5

# TODO: Finish dev and remove the exports
# the exports make no compromise nimwad. these are for creating resources in editor.
