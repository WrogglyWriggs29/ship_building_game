class_name ModuleMatrix
extends Object

var width: int = 0
var height: int = 0
var matrix: Matrix

# expects a 2d array of either modules or nulls
func _init(_matrix: Array) -> void:
	var input_width = _matrix[0].size()
	var input_height = _matrix.size()

	width = input_width
	height = input_height

	for i in range(_matrix.size()):
		for j in range(_matrix[i].size()):
			if _matrix[i][j] == null:
				_matrix[i][j] = OptionalModule.new(false)
			else:
				_matrix[i][j] = OptionalModule.new(true, _matrix[i][j])

	matrix = Matrix.new(_matrix)

func adjacent_index(index: Vector2i, direction: int) -> Vector2i:
	assert(direction >= 0 && direction <= 3, "Direction must be an integer between zero and three.")
	match direction:
		0:
			return Vector2i(index.x, index.y - 1)
		1:
			return Vector2i(index.x + 1, index.y)
		2:
			return Vector2i(index.x, index.y + 1)
		3:
			return Vector2i(index.x - 1, index.y)
		_:
			return adjacent_index(index, 0)

func in_range(index: Vector2i) -> bool:
	return index.x >= 0 && index.x < width && index.y >= 0 && index.y < height

func at(x: int, y: int) -> OptionalModule:
	return matrix.at(x, y)

func at_index(index: Vector2i) -> OptionalModule:
	return at(index.x, index.y)

func at_connection_index(index: Vector2i) -> OptionalModule:
	return at(floor(index.x / 2.0), floor(index.y / 2.0))

# returns the closest module to pos globally
# excludes modules too far from pos, so can return null
func get_closest_module(pos: Vector2) -> Module:
	var candidates: Array[Module] = []
	for x in range(width):
		for y in range(height):
			#if matrix.at(x, y).exists && matrix.at(x, y).module.get_global_square().has_point(pos):
			candidates.push_back(matrix.at(x, y).module)
	
	var closest: Module = null
	var closest_dist: float = +INF
	for module in candidates:
		var dist = (module.global_position - pos).length()
		if dist < closest_dist:
			closest = module
			closest_dist = dist
	
	return closest

func manual_physics_process() -> void:
	for x in range(width):
		for y in range(height):
			if matrix.at(x, y).exists:
				matrix.at(x, y).module.manual_physics_process()

func draw_module_dots(drawer: Node2D) -> void:
	const SCALE = 5.0
	for x in range(width):
		for y in range(height):
			if matrix.at(x, y).exists:
				drawer.draw_circle(matrix.at(x, y).module.global_position, SCALE, Color.LIGHT_BLUE)

func draw_module_rotations(drawer: Node2D) -> void:
	const SCALE = 20.0
	const WIDTH = 3.0
	for x in range(width):
		for y in range(height):
			if matrix.at(x, y).exists:
				var start = matrix.at(x, y).module.global_position
				var direction = matrix.at(x, y).module.phys_rotation.to_vector()
				var end = start + direction * SCALE
				drawer.draw_line(start, end, Color.BLACK, WIDTH)

func add_modules_as_children_to(parent: Node) -> void:
	for x in range(width):
		for y in range(height):
			if matrix.at(x, y).exists:
				parent.add_child(matrix.at(x, y).module)
