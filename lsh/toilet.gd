extends StaticBody2D

const STARTING_HEALTH: int = 3

var health: int = STARTING_HEALTH: set = set_health
var in_use: bool = false

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

func hit(by):
	health -= 1
	if health <= 0:
		queue_free()

func _exit_tree():
	if in_use:
		Utils.PLAYER.stop_hiding()
