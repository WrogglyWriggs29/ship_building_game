class_name UserVelocityApplicator
extends Node2D

var linked_module: Module = null
var velocity: Vector2 = Vector2(0, 0)
var mods: ModuleMatrix
var camera: ShipCamera

const STRENGTH = 0.1

func _init(matrix: ModuleMatrix, _camera: ShipCamera) -> void:
	linked_module = null
	velocity = Vector2(0, 0)
	mods = matrix
	camera = _camera

func _process(_delta: float) -> void:
	if linked_module:
		var mouse_pos = get_global_mouse_position()
		calc_velocity(mouse_pos)
		queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var dragging = mods.get_closest_module(get_global_mouse_position()) # event.global_position + camera.global_position)
			if dragging:
				link(dragging)
		else:
			apply_velocity()
	
	queue_redraw()

func _draw() -> void:
	if linked_module:
		draw_line(linked_module.global_position, linked_module.global_position + velocity / STRENGTH, Color.BLUE_VIOLET)

func link(module: Module) -> void:
	linked_module = module

func unlink() -> void:
	linked_module = null

func calc_velocity(mouse_pos: Vector2) -> void:
	velocity = (mouse_pos - linked_module.global_position) * STRENGTH

func apply_velocity() -> void:
	if linked_module:
		linked_module.velocity += velocity
		velocity = Vector2(0, 0)

	linked_module = null
