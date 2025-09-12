extends CharacterBody2D
var Friction = 0.8
@onready var vision_ray = $RayCast2D
@onready var nav_agent = $NavigationAgent2D
var speed = 16
@export var damage = 5
@export var knockback = 100 
var target
@onready var last_seen = global_position
var searching: bool = false
var target_vision = false
var next_point
var direction
func _ready() -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = null
		target_vision = false
		start_searching()
	
func _physics_process(delta: float) -> void:
	if target:
		vision_ray.set_target_position(vision_ray.to_local(target.global_position))
		if vision_ray.is_colliding():
			var hit = vision_ray.get_collider()
			if hit == target:
				target_vision = true
				last_seen = target.global_position
				nav_agent.target_position = last_seen
				next_point = nav_agent.get_next_path_position()
				direction = (next_point - global_position).normalized()
				velocity += direction * speed
				searching = false
			else:
				target_vision = false
				start_searching()
		
	if searching:
		if nav_agent.is_navigation_finished():
			searching = false
			return
		next_point = nav_agent.get_next_path_position()
		direction = (next_point - global_position).normalized()
		velocity += direction * speed
	velocity.x *= Friction
	velocity.y *= Friction
	move_and_slide()

func start_searching():
	nav_agent.avoidance_enabled = true
	nav_agent.target_position = last_seen
	searching = true
