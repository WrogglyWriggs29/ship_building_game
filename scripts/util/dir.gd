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

static func to_vector(dir: int) -> Vector2:
	assert_dir(dir)
	match dir:
		UP:
			return Vector2(0, -1)
		RIGHT:
			return Vector2(1, 0)
		DOWN:
			return Vector2(0, 1)
		LEFT:
			return Vector2(-1, 0)
		_:
			return Vector2(0, -1)

static func to_angle(dir: int) -> float:
	assert_dir(dir)
	match dir:
		UP:
			return PI / 2
		RIGHT:
			return 0
		DOWN:
			return -PI / 2
		LEFT:
			return PI
		_:
			return PI / 2