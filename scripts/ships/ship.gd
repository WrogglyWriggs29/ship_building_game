class_name Ship
extends Node2D

var actions: ActionBinder = ActionBinder.new()
var grids: Array[ShipGrid] = []

func _init(_grids: Array[ShipGrid], _actions) -> void:
	grids = _grids
	actions = _actions

func _ready() -> void:
	for grid in grids:
		add_child(grid)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			actions.trigger(event.keycode)
		else:
			actions.untrigger(event.keycode)

func manual_physics_process() -> void:
	for grid in grids:
		grid.manual_physics_process()

func get_average_position() -> Vector2:
	if grids.is_empty():
		return Vector2.ZERO

	var total_position = Vector2.ZERO
	var count = 0

	for grid in grids:
		var grid_position = grid.get_average_position()
		#print("avg: ", grid_position)
		if grid_position != Vector2.ZERO:
			total_position += grid_position
			count += 1
		#print("grid position of ", grid_position, " ", count)

	if count == 0:
		return Vector2.ZERO

	return total_position / count
