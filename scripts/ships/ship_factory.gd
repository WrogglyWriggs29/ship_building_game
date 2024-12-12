class_name ShipFactory
extends Node

const OFFSET = Vector2(0, 0)
const SCALE = 100.0

var in_tree: bool

func _init() -> void:
	in_tree = false

func _ready() -> void:
	in_tree = true

func validate(bp: ShipGridBlueprint) -> String:
	if bp == null:
		return "Blueprint is null."
	
	if bp.width <= 0 or bp.height <= 0:
		return "Blueprint has invalid dimensions: " + str(bp.width) + "x" + str(bp.height) + "."
	
	var module_indices: Dictionary = {}
	for x in bp.width:
		for y in bp.height:
			var pair = bp.matrix.at(x, y)
			if pair.structure.type != StructureBlueprint.Type.EMPTY:
				module_indices[Vector2i(x, y)] = false
	
	if module_indices.size() == 0:
		return "Blueprint is blank."
	
	var first = module_indices.keys().front()
	mark_adjacent(bp, module_indices, first)

	for index in module_indices.keys():
		if not module_indices[index]:
			return "Blueprint has disconnected modules."
	

	return ""

func from_grid(bp: ShipGridBlueprint) -> Ship:
	var grid = ShipGridBuilder.build(bp, OFFSET, SCALE)

	grid.name = "ship grid 0 from " + bp.name

	var ship = Ship.new([grid], ActionBinder.new())
	for key in bp.actions.keys():
		var action_indices = bp.actions[key]
		for index in action_indices:
			var optional_part = grid.factory.modules.at_index(index)
			if optional_part.exists:
				ship.actions.bind(key, optional_part.part)

	return ship

# depth first search across connections to find all connected modules and mark them true in dict
func mark_adjacent(bp: ShipGridBlueprint, dict: Dictionary, index: Vector2i) -> void:
	dict[index] = true
	for dir in Dir.MAX:
		var connection = bp.connections_at(index.x, index.y)[dir]
		if connection:
			var adjacent = BlueprintEditor.increment_index_by_dir(index, dir)
			if dict.has(adjacent) and not dict[adjacent]:
				mark_adjacent(bp, dict, adjacent)
