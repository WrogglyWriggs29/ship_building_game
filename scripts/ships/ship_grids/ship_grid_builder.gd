class_name ShipGridBuilder
extends Object

# a factory that takes a blueprint object and creates a ship grid


# for easy testing, uses a simplified blueprint string format
# each row is separated by a newline
# each module is represented by a character
# connections are always assumed to exist for non-empty modules
# offset and scale are used to determine the starting position of each module
static func debug_build(blueprint_string: String, offset: Vector2, scale: float) -> ShipGrid:
	var modules = []
	var connections = []
	var index = Vector2i(0, 0)

	var rows = blueprint_string.split("\n")

	var module_row = []
	var connection_row1 = []
	var connection_row2 = []
	while true:
		if index.x >= rows[index.y].length():
			index.x = 0
			index.y += 1

			modules.push_back(module_row)
			connections.push_back(connection_row1)
			connections.push_back(connection_row2)
			module_row = []
			connection_row1 = []
			connection_row2 = []

		if index.y >= rows.size():
			break
		
		var module_char = rows[index.y][index.x]
		match module_char:
			"e":
				module_row.push_back(null)

				connection_row1.append_array([null, null])
				connection_row2.append_array([null, null])
			"d":
				var module = Module.new(Module.Type.DEBUG, position_from_index(index, scale) + offset)
				module.name = "debug" + str(id_from_index(index, rows[0].length()))

				print("Adding module " + module.name + " at " + str(module.position))
				module_row.push_back(module)

				connection_row1.append_array([Connection.basic_spring(scale), Connection.basic_spring(scale)])
				connection_row2.append_array([Connection.basic_spring(scale), Connection.basic_spring(scale)])
		index.x += 1

	return ShipGrid.new(ModuleMatrix.new(modules), ConnectionMatrix.new(connections), [])

static func build(bp: ShipGridBlueprint, offset: Vector2, scale: float) -> ShipGrid:
	var modules = []
	var factory_states = []
	var connections = []
	for y in bp.height:
		var module_row = []
		var connection_row1 = []
		var connection_row2 = []
		var factory_state_row = []
		for x in bp.width:
			var pair = bp.matrix.at(x, y)
			if pair.structure.type == StructureBlueprint.Type.EMPTY:
				module_row.push_back(null)
				connection_row1.append_array([null, null])
				connection_row2.append_array([null, null])
				factory_state_row.push_back(null)
			else:
				module_row.push_back(Module.new(bp.module_type_at(x, y), position_from_index(Vector2(x, y), scale) + offset))

				var cons: Array[bool] = bp.connections_at(x, y)
				connection_row1.push_back(null if not cons[0] else Connection.basic_spring(scale))
				connection_row1.push_back(null if not cons[1] else Connection.basic_spring(scale))
				connection_row2.push_back(null if not cons[3] else Connection.basic_spring(scale))
				connection_row2.push_back(null if not cons[2] else Connection.basic_spring(scale))

				var part = GridFactory.FactoryPartState.new()
				part.type = pair.part.type
				part.orientation = pair.part.orientation
				part.inventory = pair.part.starting_inventory
				match part.type:
					GridFactory.FactoryPartState.Type.THRUSTER:
						part.action_cooldown_max = 0
					GridFactory.FactoryPartState.Type.GUN:
						part.action_cooldown_max = 20
				factory_state_row.push_back(part)


		modules.push_back(module_row)
		connections.push_back(connection_row1)
		connections.push_back(connection_row2)
		factory_states.push_back(factory_state_row)

	var grid = ShipGrid.new(ModuleMatrix.new(modules), ConnectionMatrix.new(connections), factory_states)

	return grid

# starting at start_mod, does a tree search to copy (references to) all connected modules, connections, and factory parts
static func tree_copy_existing(grid: ShipGrid, start_mod: Vector2i) -> ShipGrid:
	var tabula = blank(grid.width, grid.height)

	var visited = {}
	var queue = [start_mod]
	visited[start_mod] = true

	var min_i = Vector2i(grid.soft_body.modules.width - 1, grid.soft_body.modules.height - 1)
	var max_i = Vector2i.ZERO

	while queue.size() > 0:
		var current = queue.pop_front()
		if current.x < min_i.x:
			min_i.x = current.x
		if current.x > max_i.x:
			max_i.x = current.x
		if current.y < min_i.y:
			min_i.y = current.y
		if current.y > max_i.y:
			max_i.y = current.y

		copy_index_into(grid, tabula, current)

		for dir in Dir.MAX:
			var next_con = grid.soft_body.connections.index_from_module(current, dir)
			var next_mod = grid.soft_body.modules.adjacent_index(current, dir)
			if grid.connection_exists(next_con) and not visited.has(next_mod):
				queue.append(next_mod)
				visited[next_mod] = true
	
	# trim the grid to only include the copied modules
	print("Min index " + str(min_i) + " Max index " + str(max_i))
	var trimmed_blank = blank(max_i.x - min_i.x + 1, max_i.y - min_i.y + 1)
	for x in range(min_i.x, max_i.x + 1):
		for y in range(min_i.y, max_i.y + 1):
			copy_index_into(tabula, trimmed_blank, Vector2i(x, y), min_i)
	

	return trimmed_blank

static func copy_index_into(grid: ShipGrid, tabula: ShipGrid, index: Vector2i, offset: Vector2i = Vector2i.ZERO) -> void:
	# module
	var mod = grid.soft_body.modules.at_index(index)
	tabula.soft_body.modules.matrix.set_at_index(index - offset, mod)

	# connections
	for dir in Dir.MAX:
		var con = grid.soft_body.connections.index_from_module(index, dir)
		var con_new = grid.soft_body.connections.index_from_module(index - offset, dir)
		if grid.connection_exists(con):
			tabula.soft_body.connections.matrix.set_at_index(con_new, grid.soft_body.connections.at_index(con))

	# part
	var part = grid.factory.modules.at_index(index)
	tabula.factory.modules.set_at_index(index - offset, part)

class ConnectionChunk:
	var cons: Array[Connection]
	
	func _init(_cons: Array[Connection] = [null, null, null, null]) -> void:
		cons = _cons
	
	func set_con(dir: int, con: Connection) -> void:
		Dir.assert_dir(dir)
		cons[dir] = con
	
	func get_con(dir: int) -> Connection:
		Dir.assert_dir(dir)
		return cons[dir]

class ModuleState:
	var module: Module
	var part: GridFactory.FactoryPartState
	var cons: ConnectionChunk

	func _init(_module: Module, _part: GridFactory.FactoryPartState, _cons: ConnectionChunk) -> void:
		module = _module
		part = _part
		cons = _cons

	static func blank() -> ModuleState:
		return ModuleState.new(null, null, ConnectionChunk.new())

static func blank(width: int, height: int) -> ShipGrid:
	var mods = []
	var cons = []
	var parts = []
	for y in range(height):
		var mod_row = []
		var con_row1 = []
		var con_row2 = []
		var part_row = []
		for x in range(width):
			mod_row.push_back(null)
			con_row1.append_array([null, null])
			con_row2.append_array([null, null])
			part_row.push_back(null)
		mods.push_back(mod_row)
		cons.push_back(con_row1)
		cons.push_back(con_row2)
		parts.push_back(part_row)
	
	return ShipGrid.new(ModuleMatrix.new(mods), ConnectionMatrix.new(cons), parts)
	

static func position_from_index(index: Vector2i, scale: float) -> Vector2:
	return Vector2(index.x * scale, index.y * scale)

static func id_from_index(index: Vector2i, row_size: int) -> int:
	return index.y * row_size + index.x
