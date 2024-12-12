class_name SharedVector
extends RefCounted

var value: Vector2 = Vector2.ZERO

var held_by: Array = []

func _init(_value: Vector2 = Vector2.ZERO, _held_by: Array = []) -> void:
    value = _value
    held_by = _held_by

func x() -> float:
    return value.x

func y() -> float:
    return value.y