class_name BlueprintWriter
extends Object

# Error messages
const ERR_FILE_WRITE = "Could not write blueprint file"

static func write_file(blueprint: ShipGridBlueprint, path: String) -> bool:
	# Get blueprint data
	var data = get_save_data(blueprint)  # Changed from _get_save_data to get_save_data
	
	# Convert to JSON
	var json_string = JSON.stringify(data, "  ") # Use 2 spaces for indentation
	
	# Write to file
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error(ERR_FILE_WRITE)
		return false
		
	file.store_string(json_string)
	file.close()
	return true

static func save_blueprint(blueprint: ShipGridBlueprint, name: String) -> bool:
	
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("blueprints"):
		dir.make_dir("blueprints")
	
	# Create full path
	var path = "user://blueprints/" + name + ".blueprint"
	print("Saving blueprint to: ", path)
	
	# Write blueprint file
	return write_file(blueprint, path)

# Renamed from _get_save_data to get_save_data and made it public
static func get_save_data(blueprint: ShipGridBlueprint) -> Dictionary:
	var data = {
		"width": blueprint.width,
		"height": blueprint.height,
		"grid": [],
		"actions": {}
	}
	
	# Save grid data
	for y in range(blueprint.height):
		var row = []
		for x in range(blueprint.width):
			var pair = blueprint.matrix.at_index(Vector2i(x, y))
			var cell_data = {
				"structure_type": pair.structure.type,
				"connections": pair.structure.connections,
				"part_type": pair.part.type,
				"orientation": pair.part.orientation
			}
			row.append(cell_data)
		data["grid"].append(row)
	
	# Save actions
	for key in blueprint.actions:
		data["actions"][str(key)] = blueprint.actions[key]
	
	return data
