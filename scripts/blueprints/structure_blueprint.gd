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

func flip_connection(dir: int) -> void:
	Dir.assert_dir(dir)
	connections[dir] = not connections[dir]

static func type_name(_type: Type) -> String:
	match _type:
		Type.EMPTY:
			return "Empty"
		Type.DEBUG:
			return "Debug"
		_:
			return "Unknown"
