class_name BlueprintEditor
extends Node

var blueprint: ShipGridBlueprint

func _init(_blueprint: ShipGridBlueprint) -> void:
	blueprint = _blueprint

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

func set_part(index: Vector2i, type: FactoryPartBlueprint.Type, orientation: int) -> void:
	Dir.assert_dir(orientation)
	if not blueprint.matrix.in_range(index):
		return

	var pair = blueprint.matrix.at_index(index)
	pair.part.type = type
	pair.part.orientation = orientation