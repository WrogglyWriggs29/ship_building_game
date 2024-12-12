class_name BlueprintEditor
extends Node

var blueprint: ShipGridBlueprint

func _init(_blueprint: ShipGridBlueprint) -> void:
	blueprint = _blueprint

func set_blueprint(new_blueprint: ShipGridBlueprint) -> void:
	blueprint = new_blueprint

func read_dims() -> Vector2i:
	return Vector2i(blueprint.matrix.width, blueprint.matrix.height)

func read_structure_type(index: Vector2i) -> StructureBlueprint.Type:
	if not blueprint.matrix.in_range(index):
		return StructureBlueprint.Type.EMPTY

	var pair = blueprint.matrix.at_index(index)
	return pair.structure.type

func set_structure_type(index: Vector2i, type: StructureBlueprint.Type) -> void:
	if not blueprint.matrix.in_range(index):
		return

	var pair = blueprint.matrix.at_index(index)
	pair.structure.type = type

func read_part_type(index: Vector2i) -> FactoryPartBlueprint.Type:
	if not blueprint.matrix.in_range(index):
		return FactoryPartBlueprint.Type.EMPTY

	var pair = blueprint.matrix.at_index(index)
	return pair.part.type

func set_part_type(index: Vector2i, type: FactoryPartBlueprint.Type) -> void:
	if not blueprint.matrix.in_range(index):
		return

	var pair = blueprint.matrix.at_index(index)
	pair.part.type = type

func read_part_orientation(index: Vector2i) -> int:
	if not blueprint.matrix.in_range(index):
		return Dir.UP

	var pair = blueprint.matrix.at_index(index)
	return pair.part.orientation

func set_part_orientation(index: Vector2i, orientation: int) -> void:
	Dir.assert_dir(orientation)
	if not blueprint.matrix.in_range(index):
		return

	var pair = blueprint.matrix.at_index(index)
	pair.part.orientation = orientation

func set_part(index: Vector2i, type: FactoryPartBlueprint.Type, orientation: int) -> void:
	Dir.assert_dir(orientation)
	if not blueprint.matrix.in_range(index):
		return

	var pair = blueprint.matrix.at_index(index)
	pair.part.type = type
	pair.part.orientation = orientation

func read_connection(index: Vector2i, dir: int) -> bool:
	Dir.assert_dir(dir)
	if not blueprint.matrix.in_range(index):
		return false

	var pair = blueprint.matrix.at_index(index)
	return pair.structure.connections[dir]

func set_connection(index: Vector2i, dir: int, value: bool) -> void:
	Dir.assert_dir(dir)
	if not blueprint.matrix.in_range(index):
		return

	var pair = blueprint.matrix.at_index(index)
	match value:
		true:
			var neighbor_index = increment_index_by_dir(index, dir)
			if not blueprint.matrix.in_range(neighbor_index):
				return

			var neighbor_pair = blueprint.matrix.at_index(neighbor_index)
			if neighbor_pair.structure.type == StructureBlueprint.Type.EMPTY:
				return

			pair.structure.connections[dir] = value
		false:
			pair.structure.connections[dir] = false

func connected_to(index: Vector2i, dir: int) -> bool:
	Dir.assert_dir(dir)
	if not blueprint.matrix.in_range(index):
		return false

	var pair = blueprint.matrix.at_index(index)
	return pair.structure.connections[dir]

func flip_connection_bools(index: Vector2i, dir: int) -> void:
	Dir.assert_dir(dir)

	var neighbor_index = increment_index_by_dir(index, dir)
	if not blueprint.matrix.in_range(neighbor_index):
		return
	if blueprint.matrix.at_index(neighbor_index).structure.type == StructureBlueprint.Type.EMPTY:
		return

	set_connection(index, dir, not read_connection(index, dir))
	set_connection(neighbor_index, Dir.reverse(dir), not read_connection(neighbor_index, Dir.reverse(dir)))

func set_adjacent_connections(index: Vector2i, value: bool) -> void:
	for dir in Dir.MAX:
		var neighbor = increment_index_by_dir(index, dir)
		if blueprint.matrix.in_range(neighbor) and read_structure_type(neighbor) != StructureBlueprint.Type.EMPTY:
			set_connection(index, dir, value)
			set_connection(neighbor, Dir.reverse(dir), value)

func unbind(index: Vector2i) -> void:
	for key in blueprint.actions.keys():
		if blueprint.actions[key].has(index):
			blueprint.actions[key].erase(index)

func read_keybind(index: Vector2i) -> int:
	for key in blueprint.actions.keys():
		if blueprint.actions[key].has(index):
			return key
	return -1

func set_keybind(index: Vector2i, key: int) -> void:
	unbind(index)

	if blueprint.actions.has(key) and not blueprint.actions[key].has(index):
		blueprint.actions[key].push_back(index)
	elif not blueprint.actions.has(key):
		blueprint.actions[key] = [index]

static func increment_index_by_dir(index: Vector2i, dir: int) -> Vector2i:
	Dir.assert_dir(dir)
	match dir:
		Dir.UP:
			return index + Vector2i(0, -1)
		Dir.RIGHT:
			return index + Vector2i(1, 0)
		Dir.DOWN:
			return index + Vector2i(0, 1)
		Dir.LEFT:
			return index + Vector2i(-1, 0)
		_:
			return index + Vector2i(0, -1)
