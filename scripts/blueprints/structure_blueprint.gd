class_name StructureBlueprint
extends Node

var type: StructureType
var connections: Array[bool]

func _init(_type: StructureType, _con = [false, false, false, false]) -> void:
    type = _type
    connections = _con