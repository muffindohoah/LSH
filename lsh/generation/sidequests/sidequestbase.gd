extends Resource
class_name SideQuest

const default_quest_len: int = 1

@export var sidequest_name: String = "test name"
@export var quest_room: PackedScene
@export var quest_length: int = default_quest_len
@export var quest_icon: Texture
