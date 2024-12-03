class_name ConnectionMatrix
extends Node

# connections are stored as such:
# for a module like 
#   A
# D o B
#   C
# the connections are stored as
#  A B 
#  D C
# in the matrix

# this means the connection matrix should be twice as wide and tall as the module matrix

var width: int = 0
var height: int = 0
var matrix: Matrix

func _init(_matrix_array: Array) -> void:
	var input_width = _matrix_array[0].size()
	var input_height = _matrix_array.size()

	for row in _matrix_array:
		assert(row.size() == input_width, "Connection matrix has inconsistent row sizes.")
	
	assert(input_height % 2 == 0, "Connection matrix height must be even.")
	assert(input_width % 2 == 0, "Connection matrix width must be even.")

	for i in range(_matrix_array.size()):
		for j in range(_matrix_array[i].size()):
			if _matrix_array[i][j] == null:
				_matrix_array[i][j] = OptionalConnection.new(false)
			else:
				_matrix_array[i][j] = OptionalConnection.new(true, _matrix_array[i][j])

	width = input_width
	height = input_height
	matrix = Matrix.new(_matrix_array)

func index_from_module(module_index: Vector2i, dir: int) -> Vector2i:
	Dir.assert_dir(dir)
	match dir:
		Dir.UP:
			return Vector2i(module_index.x * 2, module_index.y * 2)
		Dir.RIGHT:
			return Vector2i(module_index.x * 2 + 1, module_index.y * 2)
		Dir.DOWN:
			return Vector2i(module_index.x * 2 + 1, module_index.y * 2 + 1)
		Dir.LEFT:
			return Vector2i(module_index.x * 2, module_index.y * 2 + 1)
		_:
			return Vector2i(-1, -1)

func connection_from_module(module_index: Vector2i, dir: int) -> OptionalConnection:
	Dir.assert_dir(dir)
	match dir:
		Dir.UP:
			return matrix.at(module_index.x * 2, module_index.y * 2)
		Dir.RIGHT:
			return matrix.at(module_index.x * 2 + 1, module_index.y * 2)
		Dir.DOWN:
			return matrix.at(module_index.x * 2 + 1, module_index.y * 2 + 1)
		Dir.LEFT:
			return matrix.at(module_index.x * 2, module_index.y * 2 + 1)
		_:
			return OptionalConnection.new(false)

func at(x: int, y: int) -> OptionalConnection:
	return matrix.at(x, y)

func at_index(index: Vector2i) -> OptionalConnection:
	return at(index.x, index.y)

func in_range(index: Vector2i) -> bool:
	return index.x >= 0 && index.x < width && index.y >= 0 && index.y < height

func linked_index(index: Vector2i) -> Vector2i:
	# A
	if index.x % 2 == 0 && index.y % 2 == 0:
		return Vector2i(index.x + 1, index.y - 1)
	# B
	elif index.x % 2 == 1 && index.y % 2 == 0:
		return Vector2i(index.x + 1, index.y + 1)
	# C
	elif index.x % 2 == 1 && index.y % 2 == 1:
		return Vector2i(index.x - 1, index.y + 1)
	# D
	else:
		return Vector2i(index.x - 1, index.y - 1)
