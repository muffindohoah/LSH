extends Control

@onready var sprint_meter = $ProgressBar

func _init() -> void:
	Utils.GUI = self
