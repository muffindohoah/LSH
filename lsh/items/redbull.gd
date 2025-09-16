extends Node2D

const power: float = 0.8

func _ready() -> void:
	$Timer.start()

func _process(delta: float) -> void:
	Utils.PLAYER.stamina += power

func _on_timer_timeout() -> void:
	self.queue_free()
