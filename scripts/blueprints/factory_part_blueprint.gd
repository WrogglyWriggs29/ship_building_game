class_name FactoryPartBlueprint
extends Node

var type: PartType
var orientation: Dir
var starting_inventory: Inventory

func _init(_type: PartType, _orientation: Dir, _inventory: Inventory) -> void:
    type = _type
    orientation = _orientation
    starting_inventory = _inventory