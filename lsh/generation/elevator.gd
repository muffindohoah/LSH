@tool
extends Room

var door_is_open = false

func _init() -> void:
	Utils.ELEVATOR = self

func _ready() -> void:
	super._ready()
	Utils.GENERATIONCOMPLETE.connect(open_door)

func toggle_door():
	if door_is_open:
		close_door()
	else:
		open_door()

func open_door():
	if !door_is_open:
		door_is_open = true
		$AnimationPlayer.play("open")
		$AudioStreamPlayer2D.stop()
		$AudioStreamPlayer2D.stream = load("res://assets/sfx/Ding Sound Effect (Elevator) (mp3cut.net).mp3")
		$AudioStreamPlayer2D.play()

func close_door():
	if door_is_open:
		door_is_open = false
		$AnimationPlayer.play("close")
		$AudioStreamPlayer2D.stream = load("res://assets/sfx/Creepy Elevator HQ Sound Effects (mp3cut.net).mp3")
		$AudioStreamPlayer2D.play()
		

func _on_body_entered(body: Node2D) -> void:
	if body.name == "door":
		body.queue_free()
