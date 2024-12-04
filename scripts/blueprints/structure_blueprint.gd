class_name StructureBlueprint
extends Node

enum Type {
	EMPTY,
	DEBUG
}

var type: Type
var connections: Array[bool]

func _init(_type: Type, _con: Array[bool] = [false, false, false, false]) -> void:
	type = _type
	connections = _con
