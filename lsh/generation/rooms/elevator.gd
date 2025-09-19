extends Room

func _ready() -> void:
	super._ready()
	open_door()

func open_door():
	$AnimationPlayer.play("open")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "door":
		body.queue_free()
