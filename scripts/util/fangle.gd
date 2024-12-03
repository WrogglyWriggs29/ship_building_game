class_name Fangle
extends Object

# a fangle (fancy angle) is an angle that can represent multiple rotations around a circle
# unlike the standard normalized angle which is limited to -PI to PI and forgets rotations
# a fangle is represented by a normalized angle and a multiple of 2 * PI

var norm: Nangle = Nangle.new(0)
var mult: int = 0

func _init(value: float = 0) -> void:
    set_value(value)

func set_value(value: float) -> void:
    norm = Nangle.new(value)
    var sign_mult = sign(value)
    var abs_mult = floor(abs(value / (2 * PI)))
    mult = sign_mult * abs_mult

# returns the value of the fangle in a typical radian format
func get_value() -> float:
    return norm.value + mult * 2 * PI

func get_norm() -> Nangle:
    return norm

func get_mult() -> int:
    return mult

func to_vector() -> Vector2:
    return get_norm().to_vector()

# this can "lose track of rotations" if the angle changes by more than 180 degrees in a single frame
func add(value: float) -> void:
    var new_norm = norm.value + value
    if new_norm > PI:
        new_norm -= 2 * PI
        mult += 1
    elif new_norm < -PI:
        new_norm += 2 * PI
        mult -= 1
    norm = Nangle.new(new_norm)

func add_mult(mult: int) -> void:
    self.mult += mult

static func from_parts(norm: Nangle, mult: int) -> Fangle:
    var fangle = Fangle.new(0.0)
    fangle.norm = norm
    fangle.mult = mult
    return fangle

# given two fangles, return the value you add to a to get to b over the shortest angle
# the result will be a fangle
static func shortest_difference(b: Fangle, a: Fangle) -> Fangle:
    var mult_diff = b.mult - a.mult
    if mult_diff == 0:
        return Fangle.from_parts(Nangle.shortest_difference(b.get_norm(), a.get_norm()), 0)
    else:
        return Fangle.new(b.get_value() - a.get_value())