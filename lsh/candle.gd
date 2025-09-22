extends Node2D

@export var candle_light = 10

func _ready() -> void:
	Utils.PLAYER.fov += 0.05
	
	if candle_light == 0:
		Utils.PLAYER.drop_item()
		Utils.PLAYER.fov -= 0.05

func _process(delta: float) -> void:
	if candle_light > 0:
		candle_light -= 0.01
