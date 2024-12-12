class_name ShipGridBlueprint
extends Node

class BlueprintPair extends Node:
	var structure: StructureBlueprint
	var part: FactoryPartBlueprint
	
	func _init(_structure: StructureBlueprint, _part: FactoryPartBlueprint) -> void:
		structure = _structure
		part = _part

var width: int
var height: int

# 2D array of blueprint pairs
var matrix: Matrix

# Dictionary that binds keycodes to indices in the matrix
var actions: Dictionary = {}

func _init(_matrix: Array) -> void:
	matrix = Matrix.new(_matrix)
	width = matrix.width
	height = matrix.height

func module_type_at(x, y) -> Module.Type:
	return matrix.at(x, y).structure.type

func connections_at(x, y) -> Array[bool]:
	return matrix.at(x, y).structure.connections

static func blank(_width: int, _height: int) -> ShipGridBlueprint:
	var _matrix: Array = []  # Remove the type constraint here
	for y in range(_height):
		var row: Array = []  # Use untyped Array
		for x in range(_width):
			var structure = StructureBlueprint.new(StructureBlueprint.Type.EMPTY)
			var part = FactoryPartBlueprint.new(FactoryPartBlueprint.Type.EMPTY, Dir.UP, Inventory.new())
			row.push_back(BlueprintPair.new(structure, part))
		_matrix.push_back(row)
	return ShipGridBlueprint.new(_matrix)
