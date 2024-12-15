class_name MultiShipCamera
extends Camera2D

@export var ships: Array[Ship] = []

const LEASH: float = 200
const SPEED: float = 150

func _init(_ships: Array[Ship]) -> void:
	ships = _ships

func _input(event: InputEvent) -> void:
	# zoom in and out with the mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom /= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 1.1

func _process(delta: float) -> void:
	if ships.size() == 0:
		return
	var new_position = Vector2.ZERO
	for s in ships:
		new_position += s.get_average_position()
	new_position /= ships.size()

	var tr = ships[0].get_average_position()
	var bl = ships[0].get_average_position()

	for s in ships:
		for grid in s.grids:
			if large_enough(grid):
				for x in grid.soft_body.modules.width:
					for y in grid.soft_body.modules.height:
						var module = grid.soft_body.modules.at(x, y)
						if module.exists:
							var pos = module.module.phys_position
							tr = Vector2(max(tr.x, pos.x), min(tr.y, pos.y))
							bl = Vector2(min(bl.x, pos.x), max(bl.y, pos.y))

	position = (tr + bl) / 2

	var cur_width = get_viewport().size.x
	var des_width = abs(tr.x - bl.x)
	var w_ratio = cur_width / des_width

	var cur_height = get_viewport().size.y
	var des_height = abs(tr.y - bl.y)
	var h_ratio = cur_height / des_height

	var ratio = min(w_ratio, h_ratio) / 1.3 # , 0.2)
	zoom = Vector2(ratio, ratio)

	#var aspect = get_viewport().size.y / get_viewport().size.x
	#zoom.y = zoom.x * aspect

	#position = new_position

func dir(a: Vector2, b: Vector2) -> Vector2:
	return (b - a).normalized()

func dist(a: Vector2, b: Vector2) -> float:
	return (a - b).length()

func large_enough(grid: ShipGrid) -> bool:
	var w = grid.width
	var h = grid.height

	if w + h <= 4:
		return false
	
	return true