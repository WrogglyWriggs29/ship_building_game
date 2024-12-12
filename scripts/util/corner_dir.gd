class_name CornerDir
extends Node

# though we could reuse Dir for most of this, there are some utility functions that are specific to corners

const UP_LEFT = 0
const UP_RIGHT = 1
const DOWN_RIGHT = 2
const DOWN_LEFT = 3
const MAX = 4
const INVALID = -1

static func assert_corner_dir(corner_dir: int) -> void:
    assert(0 <= corner_dir && corner_dir < MAX, "Invalid corner direction provided.")

static func rotate(corner_dir: int, clockwise: bool) -> int:
    assert_corner_dir(corner_dir)
    match corner_dir:
        UP_LEFT:
            return UP_RIGHT if clockwise else DOWN_LEFT
        UP_RIGHT:
            return DOWN_RIGHT if clockwise else UP_LEFT
        DOWN_RIGHT:
            return DOWN_LEFT if clockwise else UP_RIGHT
        DOWN_LEFT:
            return UP_LEFT if clockwise else DOWN_RIGHT
        _:
            return UP_LEFT

static func dir_clockwise_from(corner_dir: int) -> int:
    assert_corner_dir(corner_dir)
    # because of the way dir works, we can just return the value, but this maybe risky if it changes in the future
    return corner_dir

static func dir_counter_clockwise_from(corner_dir: int) -> int:
    assert_corner_dir(corner_dir)
    # this rotates the corner direction counter clockwise once
    var rotated = wrap(corner_dir - 1, UP_LEFT, MAX)
    # we can then exploit the same property from above
    return rotated

static func corner_dir_clockwise_from(dir: int) -> int:
    Dir.assert_dir(dir)
    match dir:
        Dir.UP:
            return UP_RIGHT
        Dir.RIGHT:
            return DOWN_RIGHT
        Dir.DOWN:
            return DOWN_LEFT
        Dir.LEFT:
            return UP_LEFT
        _:
            return UP_LEFT

static func corner_dir_counter_clockwise_from(dir: int) -> int:
    Dir.assert_dir(dir)
    match dir:
        Dir.UP:
            return UP_LEFT
        Dir.RIGHT:
            return UP_LEFT
        Dir.DOWN:
            return DOWN_LEFT
        Dir.LEFT:
            return DOWN_RIGHT
        _:
            return UP_LEFT

static func flip_vertical(corner_dir: int) -> int:
    assert_corner_dir(corner_dir)
    match corner_dir:
        UP_LEFT:
            return DOWN_LEFT
        UP_RIGHT:
            return DOWN_RIGHT
        DOWN_RIGHT:
            return UP_RIGHT
        DOWN_LEFT:
            return UP_LEFT
        _:
            return UP_LEFT

static func flip_horizontal(corner_dir: int) -> int:
    assert_corner_dir(corner_dir)
    match corner_dir:
        UP_LEFT:
            return UP_RIGHT
        UP_RIGHT:
            return UP_LEFT
        DOWN_RIGHT:
            return DOWN_LEFT
        DOWN_LEFT:
            return DOWN_RIGHT
        _:
            return UP_LEFT