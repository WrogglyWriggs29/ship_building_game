class_name OptionalModule
extends Object

var exists: bool
var module: Module

func _init(_exists: bool, _module: Module = null) -> void:
    exists = _exists
    module = _module