class_name Connection
extends Node

enum Type {
    BASIC_SPRING
}

var type: Type = Type.BASIC_SPRING

var deadzone_size_linear: float
var k_linear: float
var breaking_force: float

var deadzone_size_angular: float
var k_angular: float
var breaking_torque: float

func _init(_type, _dzl, _kl, _bfl, _dza, _ka, _bta) -> void:
    type = _type

    # Linear constants
    deadzone_size_linear = _dzl
    k_linear = _kl
    breaking_force = _bfl

    # Angular constants
    deadzone_size_angular = _dza
    k_angular = _ka
    breaking_torque = _bta

static func basic_spring(scale) -> Connection:
    var dzl = 0.0
    var kl = 8.0
    var bf = 1000.0

    var dza = 0.0
    var ka = 6000.0
    var bt = 3000.0
    return Connection.new(Type.BASIC_SPRING, dzl, kl, bf, dza, ka, bt)