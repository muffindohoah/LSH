extends CharacterBody2D
var Friction = 0.8
var speed = 16
@onready var vision_ray = $RayCast2D
@onready var nav_agent = $NavigationAgent2D
@export var damage = 5
@export var knockback = 100 
@onready var last_seen = global_position
var target
var searching: bool = false
var target_vision = false
var next_point
var ignore_nav = false
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
			if hit == target and !target.is_hidden:
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

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("destructible"):
		if !body.is_open:
			bang_in(body)

func bang_in(body):
	for i in body.health:
		$AudioStreamPlayer2D.play()
		var body_position = body.position + Vector2(16,0)
		body.health -=1
		await get_tree().create_timer(0.8).timeout
		if body == null:
			last_seen -= (self.position - (body_position)).normalized() * 40
