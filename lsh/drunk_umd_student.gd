extends CharacterBody2D

var walk_max_speed = 150
var sprint_max_speed = 200
var current_max_speed = 150
var current_speed = 0
var accel = 3

func _physics_process(delta):
	
	movement(delta)
	
	move_and_slide()

func movement(d):
	var input_dir:Vector2 = Vector2(0,0)
	if Input.is_action_pressed("sprint"):
		current_max_speed = sprint_max_speed
	else:
		current_max_speed = walk_max_speed
	
	
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
