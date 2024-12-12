class_name Module
extends Node2D

enum Type {
	DEBUG
}

var type: Type = Type.DEBUG
var mass: float = 1.0
var velocity: Vector2 = Vector2.ZERO

var phys_position: Vector2 = Vector2.ZERO
var phys_rotation: Fangle = Fangle.new(0.0)

var debug_draw: bool = true
var debug_accel_vectors: Array[Vector2] = []

var vertices: Array[SharedVector] = [SharedVector.new(), SharedVector.new(), SharedVector.new(), SharedVector.new()]

func _init(_type, _position) -> void:
	type = _type
	position = _position
	phys_position = position
	phys_rotation = Fangle.new(0.0)
	
	mass = 0.005 * pow(GlobalConstants.SCALE, 2)
	velocity = Vector2.ZERO

func _draw() -> void:
	const ACCEL_VECTOR_SCALE = 300.0
	if debug_draw:
		for vec in debug_accel_vectors:
			draw_line(Vector2(0, 0), vec * ACCEL_VECTOR_SCALE, Color.BLUE)
		debug_accel_vectors.clear()

func _process(_delta: float) -> void:
	position = phys_position

func manual_physics_process() -> void:
	phys_position += velocity * GlobalConstants.TIME_STEP_CONSTANT

func apply_accel(accel: Vector2) -> void:
	velocity += accel
	if debug_draw:
		debug_accel_vectors.push_back(accel)
		queue_redraw()

func get_global_square() -> Rect2:
	const SIDE_LENGTH = 50.0
	return Rect2(global_position.x - SIDE_LENGTH / 2, global_position.y - SIDE_LENGTH / 2, SIDE_LENGTH, SIDE_LENGTH)

static func angle_between(a: Module, b: Module) -> Nangle:
	return Nangle.from_vector(b.position - a.position)

static func distance_between(a: Module, b: Module) -> float:
	return (b.position - a.position).length()

#         A  
#		  | T
#         | 
# a ----> b
static func tangent_direction(a: Module, b: Module) -> Vector2:
	return (b.position - a.position).rotated(PI / 2).normalized()
