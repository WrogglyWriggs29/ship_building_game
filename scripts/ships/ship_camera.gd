class_name ShipCamera
extends Camera2D

@export var ship: Ship

func _init(_ship: Ship) -> void:
	ship = _ship

func _process(delta: float) -> void:
	if ship == null:
		return
	# Lock the camera to the ship's average position
	position = ship.get_average_position()
