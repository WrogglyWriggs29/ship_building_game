class_name OptionalConnection
extends Object

var exists: bool
var connection: Connection

func _init(_exists: bool, _connection: Connection = null) -> void:
    exists = _exists
    connection = _connection