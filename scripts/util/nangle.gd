class_name Nangle
extends Object

# normalized angle between -PI and PI
# helpful to put this into a class for the utility functions that work on it
# considers y to be up, rather than down like godot


var value: float = 0

func _init(_value: float) -> void:
	value = wrapf(_value, -PI, PI)

func add(angle: float) -> Nangle:
	value = wrapf(value + angle, -PI, PI)
	return self

func add_nangle(angle: Nangle) -> void:
	add(angle.value)

# given two norm angles, return the value you add to a to get to b over the shortest angle
# the result will be in the range -PI to PI
static func shortest_difference(b: Nangle, a: Nangle) -> Nangle:
	# first move the angles into zero -> 2pi range
	var b_val = wrapf(b.value, 0, 2 * PI)
	var a_val = wrapf(a.value, 0, 2 * PI)

	# then calculate the difference
	var diff = b_val - a_val

	if diff > PI:
		diff -= 2 * PI
	elif diff < -PI:
		diff += 2 * PI
	
	return Nangle.new(diff)

static func from_dir(dir: int) -> Nangle:
	match dir:
		Dir.UP:
			return Nangle.new(PI / 2)
		Dir.RIGHT:
			return Nangle.new(0)
		Dir.DOWN:
			return Nangle.new(-PI / 2)
		Dir.LEFT:
			return Nangle.new(PI)
		_:
			return Nangle.new(0)

static func from_vector(vec: Vector2) -> Nangle:
	vec.y = -vec.y
	return Nangle.new(vec.angle())

func to_vector() -> Vector2:
	return Vector2(cos(value), -sin(value))