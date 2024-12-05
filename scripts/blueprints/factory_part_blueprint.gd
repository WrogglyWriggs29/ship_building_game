class_name FactoryPartBlueprint
extends Node

enum Type {
    EMPTY,
    DEBUG
}

var type: Type
var orientation: int
var starting_inventory: Inventory

func _init(_type: Type, _orientation: int, _inventory: Inventory) -> void:
    type = _type
    orientation = _orientation
    starting_inventory = _inventory