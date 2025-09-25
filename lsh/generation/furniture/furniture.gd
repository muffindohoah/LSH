@tool
extends StaticBody2D
@export var furniture_reference:Furniture
@export_tool_button("Update Preview") var update_preview_button = Callable(self, "update_from_reference")

const _drop_loot__posmult: int = 20

var opened: bool = false

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout

	update_from_reference()

func update_from_reference() -> void:
	if !furniture_reference:
		return
	
	
	if furniture_reference.use_random_texture:
		$Sprite2D.texture = furniture_reference.random_textures.pick_random()
	else:
		$Sprite2D.texture = furniture_reference.base_texture
	
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.size = furniture_reference.collision_vector
	
	if furniture_reference.openable:
		add_to_group("interactable")
		
	if furniture_reference.emits_light:
		$PointLight2D.enabled = true
		$PointLight2D.texture_scale = furniture_reference.light_size
	else:
		$PointLight2D.enabled = false
	
	return

func interact() -> void:
	if not opened:
		$AudioStreamPlayer2D.play()
		opened = true
		$Sprite2D.texture = furniture_reference.opened_texture
		drop_loot(Loot.get_lootation())


func drop_loot(loot) -> void:
	var loot_scene = load("res://items/droppeditem.tscn").instantiate()
	loot_scene.item_reference = loot
	get_parent().add_child(loot_scene)
	loot_scene.global_position = self.global_position 
	if furniture_reference.item_drop_pos:
		loot_scene.global_position += furniture_reference.item_drop_pos
	else:
		var direction_vector: Vector2 = Vector2(cos(rotation), sin(rotation))
		loot_scene.global_position += direction_vector * _drop_loot__posmult
