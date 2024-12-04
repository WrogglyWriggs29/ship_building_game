class_name ShipGridBlueprint
extends Node

class BlueprintPair extends Node:
    var structure: StructureBlueprint
    var part: FactoryPartBlueprint

    func _init(_structure: StructureBlueprint, _part: FactoryPartBlueprint) -> void:
        structure = _structure
        part = _part

# 2D array of blueprint pairs
var matrix
var width
var height

func _init(_matrix: Array) -> void:
    matrix = Matrix.new(_matrix)

    width = matrix.width
    height = matrix.height

func module_type_at(x, y) -> Module.Type:
    return matrix.at(x, y).structure.type

func connections_at(x, y) -> Array[bool]:
    return matrix.at(x, y).structure.connections