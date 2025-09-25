extends CharacterBody2D

const _ready__timeout_ = 0.3

# TODO: Play with these values until they feel nice, then make them const
@export var intox_speed_debuf: int = 20
@export var intox_falloff_rate: float = 0.1
@export var intox_flip_control_threshold: int = 30
@export var stamina_sprint_threshold: float = 0.5
@export var stamina_falloff_rate: float = 0.5
@export var stamina_regen_rate: float = 0.2

@export var walk_max_speed: int = 150
@export var sprint_max_speed: int = 220
@export var max_stamina: int = 100

var current_max_speed: int = 150
var current_speed: int = 0
var accel: int = 3

# TODO: Shouldn't this be at 50 or something so we don't kill the player immediately 
# on starting the game? Or have we ditched the "must be intoxicated to not go into shock from the
# pain of the lost arm" mechanic?
# fuck forcing the player to constantly get beers; with one inventory slot 
# this disincentivises holding other items + forces constant rotation of the one item. this does not allow tact. 
var intoxication: int = 0
var fov:float = 0.25: 
	set(value): 
		fov = value
		$PointLight2D.texture_scale = fov

var stamina: float = 50.0

var can_move: bool = true
var is_moving: bool = false
var is_hidden: bool = false

var held_item: Item

func _init() -> void:
	Utils.PLAYER = self

func _ready() -> void:
	await get_tree().create_timer(_ready__timeout_).timeout
	$PointLight2D.texture_scale = fov

func _physics_process(delta: float):
	status_effects(delta)
	movement(delta)
	interact(delta)
	
	if !(Utils.GUI.sprint_meter == null):
		Utils.GUI.sprint_meter.value = stamina
	
	items(delta)
	move_and_slide()

func status_effects(delta: float):
	current_max_speed -= (intoxication * intox_speed_debuf)
	if intoxication > 0:
		intoxication -= intox_falloff_rate
	print("Current intox: " + String.num_int64(intoxication))

func canSprint() -> bool:
	return (stamina >= stamina_sprint_threshold)

func movement(delta: float):
	var input_dir: Vector2 = Vector2(0, 0)
	if Input.is_action_pressed("sprint") and canSprint():
		stamina -= stamina_falloff_rate
		current_max_speed = sprint_max_speed
	else:
		if stamina < max_stamina:
			stamina += stamina_regen_rate
		current_max_speed = walk_max_speed

	
	if can_move:
		input_dir.x = 0
		input_dir.y = 0
		if Input.is_action_pressed("right"):
				input_dir.x += 1
		if Input.is_action_pressed("left"):
				input_dir.x += -1
		if Input.is_action_pressed("up"):
				input_dir.y += -1
		if Input.is_action_pressed("down"):
				input_dir.y += 1
		
		# Interesting. Getting drunk usually makes people slower
		current_max_speed += (intoxication)
		
		if input_dir != Vector2(0,0) and current_speed < current_max_speed:
			current_speed += (accel)
			is_moving = true
		
		elif input_dir == Vector2(0,0):
			is_moving = false
			current_speed = 0
			# TODO: Is it a good idea or not to make this friction-based instead of just stopping on
			# a dime?
			# friction based is better. i dont remember why it is the way it is.
		
		elif current_speed > current_max_speed:
			current_speed -= (accel)
		
		if is_moving:
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.speed_scale = current_speed/walk_max_speed
			
			var sprite_target_rotation
			
			sprite_target_rotation = self.get_angle_to(get_global_mouse_position())
			sprite_target_rotation -= 1
			$AnimatedSprite2D.rotation = sprite_target_rotation
		else:
			$AnimatedSprite2D.pause()
		
		if intoxication > intox_flip_control_threshold:
			input_dir *= -1
		
		print(current_speed)
		velocity = input_dir.normalized() * current_speed
	
	return

var interactables_in_ranges: Array = []

func interact(delta: float):
	if Input.is_action_just_pressed("interact"):
		if interactables_in_ranges.size() > 0:
			$AnimatedSprite2D.play("interact")
			interactables_in_ranges[0].interact()

var prehidden_position:Vector2

func hide_inside(body):
	velocity = Vector2(0,0)
	$CollisionShape2D.disabled = true
	prehidden_position = position
	position = body.position
	can_move = false
	is_hidden = true
	visible = false
	

func stop_hiding():
	$CollisionShape2D.disabled = false
	position = prehidden_position
	can_move = true
	is_hidden = false
	visible = true

func items(delta: float):
	if Input.is_action_just_pressed("itemuse") && held_item && held_item.can_be_used:
		if held_item.use_scene:
			var item_use_scene = held_item.use_scene.instantiate()
			add_child(item_use_scene)
			drop_item()
		else:
			drop_item()

func drop_item():
	# TODO: Is this supposed to put the item in the game-world? Currently it just deletes its existence
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
