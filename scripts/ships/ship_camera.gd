class_name ShipCamera
extends Camera2D

@export var ship: Ship = null

const LEASH: float = 200
const SPEED: float = 150

func _init(_ship: Ship = null) -> void:
	ship = _ship
	zoom = Vector2(1.0 / 1.1, 1.0 / 1.1)

func _input(event: InputEvent) -> void:
	# zoom in and out with the mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom /= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 1.1

func _process(delta: float) -> void:
	if ship == null:
		return
	# Lock the camera to the ship's average position
	var new_position = ship.get_average_position()
	var dir_to = dir(position, new_position)
	var dist_to = dist(new_position, position)
	if dist_to > LEASH:
		position = -dir_to * LEASH + new_position
	else:
		var travel_dist = SPEED * delta
		if travel_dist > dist_to:
			position = new_position
		else:
			position = position + dir_to * SPEED * delta

func assign_ship(_ship: Ship) -> void:
	ship = _ship

func dir(a: Vector2, b: Vector2) -> Vector2:
	return (b - a).normalized()

func dist(a: Vector2, b: Vector2) -> float:
	return (a - b).length()