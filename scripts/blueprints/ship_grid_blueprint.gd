class_name ShipGridBlueprint
extends Node

class BlueprintPair extends Node:
    var structure: StructureBlueprint
    var part: FactoryPartBlueprint

    func _init(_structure: StructureBlueprint, _part: FactoryPartBlueprint) -> void:
        structure = _structure
        part = _part

# 2D array of blueprint pairs
var matrix: Matrix

func _init(_matrix: Array) -> void:
    matrix = Matrix.new(_matrix)

func module_type_at(x, y) -> Module.Type:
    return matrix.at(x, y).structure.type

func connections_at(x, y) -> Array[bool]:
    return matrix.at(x, y).structure.connections

static func blank(width: int, height: int) -> ShipGridBlueprint:
    var matrix = []
    for y in range(height):
        var row = []
        for x in range(width):
            row.push_back(BlueprintPair.new(StructureBlueprint.new(StructureBlueprint.Type.EMPTY), null))
        matrix.push_back(row)
    return ShipGridBlueprint.new(matrix)