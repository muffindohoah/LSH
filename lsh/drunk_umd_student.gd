extends CharacterBody2D

var walk_max_speed = 150
var sprint_max_speed = 260
var current_max_speed = 150
var current_speed = 0
var accel = 3

var max_stamina = 100
var stamina = 100

var can_sprint = true
var is_hidden = false

func _physics_process(delta):
	movement(delta)
	
	Utils.GUI.sprint_meter.value = stamina
	move_and_slide()

func movement(d):
	var input_dir:Vector2 = Vector2(0,0)
	if Input.is_action_pressed("sprint") and can_sprint:
		stamina -= 0.5
		current_max_speed = sprint_max_speed
		if stamina == 0:
			can_sprint = false
		
	else:
		if stamina < max_stamina:
			stamina += 0.2
		current_max_speed = walk_max_speed
	
	if can_sprint == false and stamina >= max_stamina:
		can_sprint = true
	
	
	if Input.is_action_pressed("right"):
		input_dir.x = 1
	if Input.is_action_pressed("left"):
		input_dir.x = -1
	if Input.is_action_pressed("up"):
		input_dir.y = -1
	if Input.is_action_pressed("down"):
		input_dir.y = 1
	if Input.is_action_pressed("right") and Input.is_action_pressed("left"):
		input_dir.x = 0
	if Input.is_action_pressed("up") and Input.is_action_pressed("down"):
		input_dir.y = 0
	
	if input_dir != Vector2(0,0) and current_speed < current_max_speed:
		current_speed += accel 
	elif input_dir == Vector2(0,0):
		current_speed = 0
	elif current_speed > current_max_speed:
		current_speed -= accel 
	
	velocity = input_dir.normalized() * current_speed
