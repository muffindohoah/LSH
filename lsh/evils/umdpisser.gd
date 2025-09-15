extends AnimatableBody2D

var pissed:bool = false: set = set_piss
var can_piss:bool = false

func _ready() -> void:
	await get_tree().create_timer(0.8).timeout
	can_piss = true

func _physics_process(delta: float) -> void:
	if can_piss:
		$RayCast2D.target_position = to_local(Utils.PLAYER.position)
		if $RayCast2D.get_collider():
			if $RayCast2D.get_collider().is_in_group("player"):
				pissed = true
			else:
				pissed = false

func set_piss(value):
	if value == pissed:
		return
	pissed = value
	if pissed == true:
		$AudioStreamPlayer2D.play()
		Utils.PISSALERT.emit(Utils.PLAYER.position)
	else:
		pass
