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