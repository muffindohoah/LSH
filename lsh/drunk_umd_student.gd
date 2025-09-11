extends CharacterBody2D

var max_speed = 150.0
var current_speed = 0
var accel = 3

func _physics_process(delta):
	movement()

func movement():
	var input_dir:Vector2 = Vector2(0,0)
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
	if input_dir != Vector2(0,0) and current_speed < max_speed:
		current_speed += accel
	else:
		current_speed -= accel
	velocity = input_dir.normalized() * current_speed
	move_and_slide()
