class_name ShipBlueprintDesigner
extends Node2D

const GRID_TOP_LEFT = Vector2(300, 200)

enum Layer {STRUCTURE, FACTORY}

var grid: BlueprintGrid

func _init() -> void:
    grid = BlueprintGrid.new(ShipGridBlueprint.blank(4, 4))
    grid.position = GRID_TOP_LEFT
    add_child(grid)