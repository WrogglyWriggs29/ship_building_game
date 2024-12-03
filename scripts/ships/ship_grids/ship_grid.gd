class_name ShipGrid
extends Node2D

var soft_body: GridSoftBody
var factory: GridFactory

func _init(modules: ModuleMatrix, connections: ConnectionMatrix) -> void:
    soft_body = GridSoftBody.new(modules, connections)