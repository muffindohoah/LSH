extends Node2D

var candle_light = .25

func _ready() -> void:
	Utils.PLAYER.fov += candle_light
	


func _process(delta: float) -> void:
	if candle_light > 0:
		candle_light -= 0.001
	
	if candle_light == 0:
		Utils.PLAYER.fov -= .25
		Utils.PLAYER.drop_item()
		
