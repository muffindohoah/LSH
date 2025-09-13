extends CharacterBody2D

var force = 80
var weight = 0.3
var target_rotation = 0.0

var health = 3

func _physics_process(delta: float) -> void:
	rotation = lerp_angle(rotation, target_rotation, weight)
	if health <= 0:
		queue_free()

func interact():
	if Utils.PLAYER.position.y > self.position.y:
		self.target_rotation += force
	else:
		self.target_rotation -= force
	
	#(Utils.PLAYER.position - self.position).normalized() * force
