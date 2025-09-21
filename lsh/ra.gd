extends CharacterBody2D

const Friction: float = 0.8
const ChasingSpeed: int = 18
const RoamingSpeed: int = 10

var speed: int = RoamingSpeed

@onready var vision_ray: RayCast2D = $RayCast2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var chase_timer: Timer = $Timer
@onready var last_seen: Vector2 = global_position

var target: Node2D
var target_vision: bool = false
var next_point: Vector2
var ignore_nav: bool = false
var direction: Vector2

var chasing: 		bool = false
var searching: 		bool = false
var roaming: 		bool = false
var roam_range:		int = 1000
var search_range:	int = 100

var traveling: bool = false
var travel_pos: Vector2

func _ready() -> void:
	Utils.PISSALERT.connect(inbound_piss_alert)
	return

func inbound_piss_alert(pos) -> void:
	print("PISSALERT")
	if chasing:
		return
	traveling = true
	nav_agent.set_target_position(pos)
	travel_pos = pos
	return

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		chasing = true
		chase_timer.start()
		target = body
	return

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = null
		target_vision = false
		start_searching()
	return


func __movement_helper(doFriction: bool) -> void:
	next_point = nav_agent.get_next_path_position()
	direction = (next_point - global_position).normalized()
	velocity += direction * speed
	if(doFriction):
		velocity.x *= Friction
		velocity.y *= Friction
		
	return

func __handle_traveling() -> void:
	__movement_helper(true)
	move_and_slide()
	if nav_agent.is_navigation_finished():
		traveling = false
	return

func __handle_targeting() -> void:
	vision_ray.set_target_position(vision_ray.to_local(target.global_position))

	if vision_ray.get_collider() == target and !Utils.PLAYER.is_hidden:
		nav_agent.set_target_position(last_seen)
		chasing = true
		target_vision = true
		last_seen = target.global_position
		__movement_helper(false)
		searching = false
		
		if nav_agent.is_navigation_finished() and !vision_ray.get_collider() == target:
			target_vision = false
			#start_searching()
			# TODO: Why is this commented out?
	return

func __handle_searching() -> void:
	var search_iterations: int = 0
	var search_timer: Timer = $Timer3
	if search_timer.time_left == 0:
		search_timer.start()

	if nav_agent.is_navigation_finished():
		nav_agent.set_target_position(position + Vector2(randi_range(search_range,-search_range),randi_range(search_range,-search_range)))
		search_iterations += 1

	if search_iterations == 1:
		pass # TODO: What is this for? Was there going to be some behavior here?
	return

func _physics_process(delta: float) -> void:
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
	
	if traveling:
		__handle_traveling()
	
	if target:
		__handle_targeting()
	
	if searching:
		__handle_searching()
		
	if roaming:
		if nav_agent.is_navigation_finished():
			nav_agent.set_target_position(position + Vector2(randi_range(roam_range,-roam_range),randi_range(roam_range,-roam_range)))
	
	if chasing:
		speed = ChasingSpeed
		modulate.r = 0
	else:
		speed = RoamingSpeed
		modulate.r = 100
	
	__movement_helper(true)
	move_and_slide()
	return

func start_searching() -> void:
	chasing = false
	searching = true
	return

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if chasing or searching or traveling:
		if body.is_in_group("destructible"):
			if "is_open" in body:
				if !body.is_open:
					bang_in(body)
				else:
					body.interact()
			else:
				bang_in(body)

func bang_in(body):
	for i in body.health:
		print("hit")
		$AudioStreamPlayer2D.play()
		var body_position = body.position + Vector2(0,0)
		body.hit(self)
		await get_tree().create_timer(0.3).timeout
		if body == null:
			last_seen += (self.position - (body_position)).normalized() * 40
			break

func _on_timer_timeout() -> void:
	chasing = false
	roaming = true

func _on_timer_3_timeout() -> void:
	chasing = false
	searching = false
	roaming = true

func _on_timer_2_timeout() -> void:
	if target:
		if vision_ray.get_collider() == target and !Utils.PLAYER.is_hidden:
			nav_agent.set_target_position(last_seen)
