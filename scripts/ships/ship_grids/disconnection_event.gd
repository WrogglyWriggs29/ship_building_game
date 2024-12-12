class_name DisconnectionEvent
extends Node

var a: Vector2i
var b: Vector2i

func _init(_a: Vector2i, _b: Vector2i) -> void:
    a = _a
    b = _b

# needs to have the property that hash(a, b) == hash(b, a)
func hash() -> int:
    return a.x + a.y + b.x + b.y