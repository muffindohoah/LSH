extends CharacterBody2D

var walk_max_speed = 150
var sprint_max_speed = 220
var current_max_speed = 150
var current_speed = 0
var accel = 3
var intoxication = 0

var max_stamina = 100
var stamina = 100

var can_move = true
var can_sprint = true
var is_hidden = false

var held_item:Item

func _init() -> void:
	Utils.PLAYER = self

func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	

func _physics_process(delta):
	movement(delta)
	interact(delta)
	if !(Utils.GUI.sprint_meter == null):
		Utils.GUI.sprint_meter.value = stamina
	items(delta)
	move_and_slide()

func movement(d):
	var input_dir:Vector2 = Vector2(0,0)
	if Input.is_action_pressed("sprint") and can_sprint and stamina > 0.4:
		stamina -= 0.5
		current_max_speed = sprint_max_speed
		if stamina < 0.5:
			can_sprint = false
	else:
		if stamina < max_stamina:
			stamina += 0.2
		current_max_speed = walk_max_speed
	if can_sprint == false and stamina >= max_stamina:
		can_sprint = true
	
	if can_move:
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



var interactables_in_ranges = []

func interact(d):
	if Input.is_action_just_pressed("interact"):
		if interactables_in_ranges.size() > 0:
			interactables_in_ranges[0].interact()

var prehidden_position:Vector2

func hide_inside(body):
	velocity = Vector2(0,0)
	$CollisionShape2D.disabled = true
	prehidden_position = position
	position = body.position
	can_move = false
	is_hidden = true
	

func stop_hiding():
	$CollisionShape2D.disabled = false
	position = prehidden_position
	can_move = true
	is_hidden = false

func items(d):
	if Input.is_action_just_pressed("itemuse"):
		if held_item.use_scene:
			var item_use_scene = held_item.use_scene.instantiate()
			add_child(item_use_scene)
			drop_item()
		else:
			drop_item()

func drop_item():
	held_item = null
	Utils.GUI.update_ui()

func pick_up(item:Item):
	if !held_item:
		held_item = item
		Utils.GUI.update_ui()

func _on_area_2d_area_entered(area: Area2D) -> void:
	var interactable = area.get_parent()
	if interactable.is_in_group("interactable"):
		interactables_in_ranges.append(interactable)

func _on_area_2d_area_exited(area: Area2D) -> void:
	var interactable = area.get_parent()
	if interactable.is_in_group("interactable"):
		interactables_in_ranges.erase(interactable)
