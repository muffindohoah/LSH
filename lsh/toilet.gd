extends StaticBody2D

const STARTING_HEALTH: int = 3

var health: int = STARTING_HEALTH: set = set_health
var in_use: bool = false
var is_open:bool = false

func set_health(value):
	health = value
	if health == 0:
		queue_free()

func interact():
	if !Utils.PLAYER.held_item:
		return
	if Utils.PLAYER.held_item.name == "Toilet Cover":
		Utils.PLAYER.hide_inside(self)
		if in_use:
			Utils.PLAYER.stop_hiding()
		in_use = !in_use 
	else:
		if !is_open:
			drop_loot(Loot.get_lootation())
			is_open = true

func hit(by):
	health -= 1
	if health <= 0:
		queue_free()

func _exit_tree():
	if in_use:
		Utils.PLAYER.stop_hiding()

func drop_loot(loot) -> void:
	var loot_scene = load("res://items/droppeditem.tscn").instantiate()
	loot_scene.item_reference = loot
	get_parent().add_child(loot_scene)
	loot_scene.global_position = self.global_position 
	
	var direction_vector: Vector2 = Vector2(cos(rotation), sin(rotation))
	loot_scene.global_position += direction_vector * 1
	
