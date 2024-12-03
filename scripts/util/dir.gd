class_name Dir

extends Node

const UP = 0
const RIGHT = 1
const DOWN = 2
const LEFT = 3
const MAX = 4

static func reverse(dir: int) -> int:
	match dir:
		UP:
			return DOWN
		RIGHT:
			return LEFT
		DOWN:
			return UP
		LEFT:
			return RIGHT
		_:
			return UP

static func assert_dir(dir: int) -> void:
	assert(0 <= dir && dir < MAX, "Invalid direction provided.")