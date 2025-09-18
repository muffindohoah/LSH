extends CharacterBody2D

var is_open = false
var initial_rotation = 0

const force: int = 90
const weight: float = 0.3
var target_rotation: float = 0.0

var health: int = 3

func _ready() -> void:
	initial_rotation = rotation_degrees

func _physics_process(delta: float) -> void:
	rotation_degrees = lerp(rotation_degrees, target_rotation, weight)

func hit(by):
	health -= 1
	if health <= 0:
		queue_free()
	if !by.chasing:
		interact()

func interact():
	
	if is_open:
		target_rotation = 0.0
	elif Utils.PLAYER.position.y > self.position.y:
		target_rotation -= force
	else:
		target_rotation += force
	
	print(target_rotation)
	if target_rotation == initial_rotation:
		is_open = false
	else:
		is_open = true
	
	#(Utils.PLAYER.position - self.position).normalized() * force
