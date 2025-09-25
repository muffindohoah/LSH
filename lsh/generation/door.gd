class_name Door
extends CharacterBody2D

const force: int = 90
const weight: float = 0.3

var initial_rotation: float = 0
var target_rotation: float = 0
var is_open: bool = false
var health: int = 3


func _ready() -> void:
	initial_rotation = rotation_degrees

func _physics_process(delta: float) -> void:
	rotation_degrees = lerp(rotation_degrees, target_rotation, weight)

func hit(by):
	health -= 1
	if health <= 0:
		queue_free()
	if !by.chasing:
		interact()

func interact():
	if is_open:
		target_rotation = 0.0
	
	elif Utils.PLAYER.global_position.y > self.global_position.y:
		target_rotation -= force
	
	else:
		target_rotation += force
	
	print(target_rotation)
	if target_rotation == initial_rotation:
		is_open = false
		
	else:
		# TODO: We should test this and see if it makes more sense to open it instantly, like is being
		# done here, or if it's a better idea to have some set angle it needs to pass to be considered
		# open
		#i already tried an angle method... had some complications with finding the angle to shift it relative to player position.
		#this was faster. however, that is why the amount changed is called 'force' lol. was going to try to make it feel physics adjacent.
		is_open = true
	
	#(Utils.PLAYER.position - self.position).normalized() * force


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("door"):
		area.get_parent().queue_free()
	if area.is_in_group("elevator"):
		queue_free()
	print("gay",area)
