class_name Ship
extends Node2D

var grids: Array[ShipGrid] = []

func _init(_grids: Array[ShipGrid]) -> void:
    grids = _grids

func manual_physics_process() -> void:
    for grid in grids:
        grid.soft_body.manual_physics_process()