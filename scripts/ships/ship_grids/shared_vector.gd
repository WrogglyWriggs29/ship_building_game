class_name SharedVector
extends RefCounted

var value: Vector2 = Vector2.ZERO

var held_by: Array[Node] = []

func _init(_value: Vector2 = Vector2.ZERO) -> void:
    value = _value

func x() -> float:
    return value.x

func y() -> float:
    return value.y