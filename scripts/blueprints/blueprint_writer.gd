class_name BlueprintWriter
extends Node

func save_ship_grid_to_json(ship_grid: ShipGridBlueprint, file_path: String) -> void:
	if file_path == "":
		file_path = "user://ShipBlueprint.json"

	var json_data = {
		"width": ship_grid.matrix.width,
		"height": ship_grid.matrix.height,
		"grid": []
	}
	for y in range(ship_grid.matrix.height):
		var row_data = []
		for x in range(ship_grid.matrix.width):
			var pair = ship_grid.matrix.at(x, y)
			row_data.append({
				"structure": {
					"type": StructureBlueprint.type_name(pair.structure.type),
					"connections": pair.structure.connections
				},
				"part": {
					"type": FactoryPartBlueprint.type_name(pair.part.type),
					"orientation": pair.part.orientation,
					"starting_inventory": {
						"type": str(pair.part.starting_inventory.type),
						"amount": pair.part.starting_inventory.amount,
						"max_amount": pair.part.starting_inventory.max_amount
					}
				},
				"coordinate": {
					"x": x,
					"y": y
				}
			})
		json_data["grid"].append(row_data)
		
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file != null:
		json_data = JSON.stringify(json_data, "    ")
		# json_data = json.stringify(json_data)
		file.store_string((json_data))
		file.close()
		print("File saved to ", file_path)
