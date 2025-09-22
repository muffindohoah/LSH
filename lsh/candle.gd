extends Node2D

var candle_light = 1

func _ready() -> void:
	Utils.PLAYER.fov += candle_light
	
	if candle_light == 0:
		Utils.PLAYER.drop_item()
		Utils.PLAYER.fov -= 1

func _process(delta: float) -> void:
	if candle_light > 0:
		candle_light -= 0.01
