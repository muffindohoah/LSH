extends CharacterBody2D

const speed = 300.0
var direction = Vector2(0,0)

func _physics_process(delta):
	movement(delta)

func movement(d):
	if Input.is_action_just_pressed("right"):
		direction.x = 1
	if Input.is_action_just_pressed("left"):
		direction.x = -1
	if Input.is_action_just_pressed("up"):
		direction.y = -1
	if Input.is_action_just_pressed("down"):
		direction.y = 1

	if Input.is_action_just_pressed("right") and Input.is_action_just_pressed("left"):
		direction.x = 0
	if Input.is_action_just_pressed("up") and Input.is_action_just_pressed("down"):
		direction.y = 0
		
	move_and_collide(direction.normalized() * speed * d)
