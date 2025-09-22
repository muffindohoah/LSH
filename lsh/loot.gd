extends Node

const rarities: Dictionary[String, float] = {"Common" : 0.60, "Uncommon" : 0.40, "Rare":0.28, "Unique" : 0.1}

func get_lootation():
	var rng = RandomNumberGenerator.new()

	var items = dir_contents("res://items/itemfiles/")
	var weights = items2rarities(items)
	print(weights, items)
	return items[rng.rand_weighted(weights)]

func items2rarities(itemsarray):
	var ret_array = []
	for item in itemsarray:
		ret_array.append(rarities[rarities.keys()[item.rarity]])
	return ret_array

func dir_contents(path):
	var scene_loads = []
	var dir = DirAccess.open(path)
	
	if !dir:
		print("An error occurred when trying to access the path.")
		return null
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
		
	while file_name != "":
		if dir.current_is_dir():
			print("Found directory: " + file_name)
		else:
			if file_name.get_extension() == "tres":
				var full_path = path.path_join(file_name)
				scene_loads.append(load(full_path))
		file_name = dir.get_next()
	
	return scene_loads
	# TODO: This is the second time I've seen this function nearly word for word. Extract it into a
	# separate function shared across files
