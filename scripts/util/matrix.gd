class_name Matrix
extends Node

class Row extends Node:
	var members: Array[Variant]
	func _init(array = []):
		members = array

var rows: Array[Row]

func _init(array = []):
	rows = []
	if array.size() > 0:
		var row_length = array[0].size()
		for i in range(array.size()):
			assert(array[i] is Array, "Matrices are initialized by a 2D array.")
			assert(array[i].size() == row_length, "All rows must have the same length.")
			rows.append(Row.new(array[i]))

func at(x: int, y: int) -> Variant:
	return rows[y].members[x]

func set_at(x: int, y: int, value: Variant) -> void:
	rows[y].members[x] = value

func at_index(index: Vector2i) -> Variant:
	return at(index.x, index.y)

func set_at_index(index: Vector2i, value: Variant) -> void:
	set_at(index.x, index.y, value)

static func make_array(width: int, height: int, default_value: Variant = null) -> Array:
	var array = []
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(default_value)
		array.append(row)
	return array
