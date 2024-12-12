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
	for i in grids.size():
		var grid = grids[i]
		var dc: Array[DisconnectionEvent] = grid.manual_physics_process()
		var already_done = {}
		for event in dc:
			if already_done.has(event.hash()):
				continue
			else:
				already_done[event.hash()] = true

			print(grid.name_str() + "Disconnecting ", event.a, " and ", event.b)

			var cons = grid.soft_body.connections.connecting(event.a, event.b)
			grid.assert_valid_connection_pair(cons, event)

			grid.disconnect_cons(cons[0], cons[1])
			if not grid.find_from(cons[0], cons[1]):
				print("Grid split detected.")
				var new_grids: Array[ShipGrid] = split_grid(grid.mod_of_con(cons[0]), grid.mod_of_con(cons[1]), grid)
				for new_grid in new_grids:
					new_grid.clear_vertices()
					grids.push_back(new_grid)
					add_child(new_grid)
				remove_child(grid)
				grids.remove_at(i)
				i -= 1
				# we don't want to process the other disconnections on the old grid
				break

# create two new equally sized blank grids, one for each side of the disconnection, 
# then copy the modules and connections from the original grid to the new grids in a tree search
func split_grid(a: Vector2i, b: Vector2i, grid: ShipGrid) -> Array[ShipGrid]:
	var grid_a = ShipGridBuilder.tree_copy_existing(grid, a)
	var grid_b = ShipGridBuilder.tree_copy_existing(grid, b)

	return [grid_a, grid_b]

func get_average_position() -> Vector2:
	if grids.is_empty():
		return Vector2.ZERO

	var total_position = Vector2.ZERO
	var count = 0

	for grid in grids:
		var avg_data: Array = grid.get_position_sum()
		total_position += avg_data[0]
		count += avg_data[1]

	if count == 0:
		return Vector2.ZERO

	return total_position / count
