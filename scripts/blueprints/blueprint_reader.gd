class_name BlueprintReader
extends Object

# Error messages
const ERR_FILE_NOT_FOUND = "Could not open blueprint file"
const ERR_INVALID_JSON = "Invalid blueprint file format"
const ERR_MISSING_DATA = "Blueprint file missing required data"

static func read_file(path: String) -> ShipGridBlueprint:
	# Check if file exists
	if not FileAccess.file_exists(path):
		push_error(ERR_FILE_NOT_FOUND)
		return null
		
	# Read file content
	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	# Parse JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error(ERR_INVALID_JSON)
		return null
		
	var data = json.data
	
	# Validate required fields
	if not _validate_blueprint_data(data):
		push_error(ERR_MISSING_DATA)
		return null
		
	return _create_blueprint_from_data(data)

static func _validate_blueprint_data(data: Dictionary) -> bool:
	# Check for required top-level fields
	if not data.has("width") or not data.has("height") or not data.has("grid"):
		return false
		
	# Validate grid dimensions
	var width = data["width"] as int
	var height = data["height"] as int
	var grid = data["grid"] as Array
	
	if grid.size() != height:
		return false
		
	for row in grid:
		if not row is Array or row.size() != width:
			return false
	
	return true

static func _create_blueprint_from_data(data: Dictionary) -> ShipGridBlueprint:
	var width = data["width"] as int
	var height = data["height"] as int
	var grid_data = data["grid"] as Array
	
	# Create the matrix for the blueprint
	var matrix: Array[Array] = []
	for y in range(height):
		var current_row: Array = []
		for x in range(width):
			var cell_data = grid_data[y][x]
			
			# Create structure blueprint
			var structure_type = cell_data.get("structure_type", StructureBlueprint.Type.EMPTY)
			var connections = cell_data.get("connections", [false, false, false, false])
			var structure = StructureBlueprint.new(structure_type, connections)
			
			# Create factory part blueprint
			var part_type = cell_data.get("part_type", FactoryPartBlueprint.Type.EMPTY)
			var orientation = cell_data.get("orientation", Dir.UP)
			var inventory = Inventory.new()
			var part = FactoryPartBlueprint.new(part_type, orientation, inventory)
			
			# Create the blueprint pair
			var blueprint_pair = ShipGridBlueprint.BlueprintPair.new(structure, part)
			current_row.append(blueprint_pair)
		
		matrix.append(current_row)
	
	# Create the final blueprint
	var blueprint = ShipGridBlueprint.new(matrix)
	
	# Load actions if present
	if data.has("actions"):
		for key in data["actions"]:
			var action_indices = data["actions"][key]
			blueprint.actions[int(key)] = action_indices
	
	return blueprint
