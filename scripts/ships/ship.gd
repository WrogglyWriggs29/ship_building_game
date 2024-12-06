class_name Ship
extends Node2D

var grids: Array[ShipGrid] = []

func _init(_grids: Array[ShipGrid]) -> void:
    grids = _grids

func manual_physics_process() -> void:
    for grid in grids:
        grid.soft_body.manual_physics_process()

func get_average_position() -> Vector2:
	if grids.is_empty():
		return Vector2.ZERO

	var total_position = Vector2.ZERO
	var count = 0

	for grid in grids:
		var grid_position = grid.get_average_position()
		if grid_position != Vector2.ZERO:
			total_position += grid_position
			count += 1
		print("grid position of ", grid_position, " ", count)

	if count == 0:
		return Vector2.ZERO

	return total_position / count
