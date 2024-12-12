class_name DisplacementMatrix
extends Node

var matrix: Matrix

func _init(connections: ConnectionMatrix) -> void:
	var displacement_array = Matrix.make_array(connections.width, connections.height, 0.0)
	for row in displacement_array:
		for i in range(row.size()):
			row[i] = Fangle.new(0.0)
	matrix = Matrix.new(displacement_array)

func at(x: int, y: int) -> Fangle:
	return matrix.at(x, y)

func at_index(index: Vector2i) -> Fangle:
	return at(index.x, index.y)

func from_module_index(index: Vector2i, dir: int) -> Fangle:
	assert(0 <= dir && dir <= 3, "Invalid dir for connection_index")
	match dir:
		Dir.UP:
			return matrix.at(index.x * 2, index.y * 2)
		Dir.RIGHT:
			return matrix.at(index.x * 2 + 1, index.y * 2)
		Dir.DOWN:
			return matrix.at(index.x * 2 + 1, index.y * 2 + 1)
		Dir.LEFT:
			return matrix.at(index.x * 2, index.y * 2 + 1)
		_:
			return Fangle.new(0.0)