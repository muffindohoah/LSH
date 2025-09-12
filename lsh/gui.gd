extends Control

@onready var sprint_meter = $ProgressBar
@onready var inventory_texture = $HBoxContainer/PanelContainer/TextureRect

func _init() -> void:
	Utils.GUI = self

func _ready() -> void:
	update_ui()

func update_ui():
	if !Utils.PLAYER.held_item:
		inventory_texture.texture = null
		return
	inventory_texture.texture = Utils.PLAYER.held_item.inventory_texture
