extends Node2D

@export var intox_amount: int = 10

func _ready() -> void:
	Utils.PLAYER.intoxication += intox_amount
