class_name BlueprintReader
extends Node


class BlueprintPair extends Node:
	var structure: StructureBlueprint
	var part: FactoryPartBlueprint

	func _init(_structure: StructureBlueprint, _part: FactoryPartBlueprint) -> void:
		structure = _structure
		part = _part

func load_ship_grid_from_json(file_path: String) -> ShipGridBlueprint:
	# Open the file in read mode
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Failed to open file for reading: " + file_path)
		return null

	# Read the JSON data from the file
	var json_string = file.get_as_text()
	file.close()

	var json_data = JSON.parse_string(json_string)
	if json_data == null:
		print("Failed to parse JSON: Unexpected null value.")
		return null
		
	# var json_data = json_result.result

	# Extract grid dimensions
	var width = json_data["width"]
	var height = json_data["height"]
	var grid = json_data["grid"]

	# Create the 2D matrix of BlueprintPair objects
	var matrix = []
	for y in range(height):
		var row = []
		for x in range(width):
			var pair_data = grid[y][x]

			# Reconstruct StructureBlueprint
			var structure_type = StructureBlueprint.Type.DEBUG if pair_data["structure"]["type"] == "Debug" else StructureBlueprint.Type.EMPTY
			var connections = pair_data["structure"]["connections"]
			var structure = StructureBlueprint.new(structure_type)

			# Reconstruct FactoryPartBlueprint
			var part_type = FactoryPartBlueprint.Type.DEBUG if pair_data["part"]["type"] == "Debug" else FactoryPartBlueprint.Type.EMPTY
			var orientation = pair_data["part"]["orientation"]
			var inventory_data = pair_data["part"]["starting_inventory"]

			var inventory = Inventory.new()
			var inventory_type = inventory_data["type"]
			if inventory_type == "<null>":
				inventory.type = null
			elif inventory_type == "Empty":
				inventory.type = InventoryResourceType.Type.Empty
			
			inventory.amount = inventory_data["amount"]
			inventory.max_amount = inventory_data["max_amount"]

			var part = FactoryPartBlueprint.new(part_type, orientation, inventory)

			# Combine into a BlueprintPair
			row.append(BlueprintPair.new(structure, part))
		matrix.append(row)

	# Return the populated ShipGridBlueprint
	return ShipGridBlueprint.new(matrix)
