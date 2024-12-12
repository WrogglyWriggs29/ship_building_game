class_name BlueprintGrid
extends Node2D

# two main responsibilities:
# 1. display the blueprint in a grid
#    - needs texture information for each module type
# 2. correlate mouse inputs to grid coordinates

# side length of each square in the grid when scale is 1.0
const GRID_SIZE = 100

var width: float
var height: float

# blueprint editor allows access to the blueprint the grid displays
var editor: BlueprintEditor

# the grid gets scaled first, then offset
var draw_scale: float = 1.0
var offset: Vector2 = Vector2.ZERO

# whether the user is dragging the grid
var dragging: bool = false

var layer: ShipBlueprintDesigner.Layer = ShipBlueprintDesigner.Layer.STRUCTURE

var is_selected: bool = false
var selected: Vector2i

func _init(_editor: BlueprintEditor) -> void:
	editor = _editor
	draw_scale = 1.0
	offset = Vector2.ZERO

func _process(_delta: float) -> void:
	if width <= 0 or height <= 0:
		return
	queue_redraw()

func _draw() -> void:
	var blueprint_size = editor.read_dims()
	for x in range(first_visible_x() - 1, blueprint_size.x):
		for y in range(first_visible_y() - 1, blueprint_size.y):
			if x < 0 or y < 0:
				continue

			var index = Vector2i(x, y)

			var type
			if layer == ShipBlueprintDesigner.Layer.STRUCTURE:
				type = editor.read_structure_type(index)
			else:
				type = editor.read_part_type(index)

			draw_sliced_placeholder_square(index, Vector2.ZERO, type)
			#draw_placeholder_square(index, pair.structure.type)

	draw_grid()
	draw_connections()

	if is_selected:
		draw_selection_circle(selected)

func select(index: Vector2i) -> void:
	is_selected = true
	selected = index

func deselect() -> void:
	is_selected = false

func draw_selection_circle(index: Vector2i) -> void:
	var top_left = top_left_corner(index)
	var bottom_right = top_left_corner(Vector2i(index.x + 1, index.y + 1))
	var center = (top_left + bottom_right) / 2
	var radius = draw_scale * GRID_SIZE / 2 * sqrt(2)
	draw_circle(center, radius, Color.RED, false)

func process_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_MIDDLE:
			match mouse_event.pressed:
				true:
					start_drag()
				false:
					end_drag()
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			draw_scale *= 1.1
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			draw_scale /= 1.1
	if event is InputEventMouseMotion:
		var mouse_event = event as InputEventMouseMotion
		if dragging:
			offset += mouse_event.relative
			if top_left_corner(Vector2i(0, 0)).x > 0:
				offset.x = 0
			if top_left_corner(Vector2i(0, 0)).y > 0:
				offset.y = 0

func zoom_in() -> void:
	draw_scale *= 1.1

func zoom_out() -> void:
	draw_scale /= 1.1

func start_drag() -> void:
	dragging = true

func end_drag() -> void:
	dragging = false

func drag_by(relative: Vector2) -> void:
	offset += relative
	if top_left_corner(Vector2i(0, 0)).x > 0:
		offset.x = 0
	if top_left_corner(Vector2i(0, 0)).y > 0:
		offset.y = 0

func draw_grid() -> void:
	const LINE_COLOR = Color.CADET_BLUE
	const HIGHLIGHT_COLOR = Color.RED
	var x = first_visible_x()
	var y = first_visible_y()
	while true:
		var index = Vector2i(0, y)
		var top_left = top_left_or_zero(index)

		if top_left.y > height:
			break
		else:
			y += 1

		draw_line(top_left, Vector2(width, top_left.y), LINE_COLOR)

	while true:
		var index = Vector2i(x, 0)
		var top_left = top_left_or_zero(index)

		if top_left.x > width:
			break
		else:
			x += 1

		draw_line(top_left, Vector2(top_left.x, height), LINE_COLOR)
	
	# draw the bottom and right edges of the blueprint
	var dims = editor.read_dims()

	var bottom_right = top_left_corner(Vector2i(dims.x, dims.y))
	if bottom_right.x >= 0 and bottom_right.y >= 0:
		draw_dashed_line(top_left_or_zero(Vector2i(0, dims.y)), bottom_right, HIGHLIGHT_COLOR)
		draw_dashed_line(top_left_or_zero(Vector2i(dims.x, 0)), bottom_right, HIGHLIGHT_COLOR)
	
	draw_line(Vector2.ZERO, Vector2(width, 0), Color.BLACK)
	draw_line(Vector2.ZERO, Vector2(0, height), Color.BLACK)

func draw_connections() -> void:
	var dims = editor.read_dims()
	for x in range(dims.x):
		for y in range(dims.y):
			var index = Vector2i(x, y)
			var type = editor.read_structure_type(index)
			if type == StructureBlueprint.Type.EMPTY:
				continue
			
			for dir in Dir.MAX:
				if editor.connected_to(index, dir):
					draw_connected_line(index, dir)

func draw_connected_line(index: Vector2i, dir: int) -> void:
	var top_left = top_left_corner(index)
	var bottom_right = top_left_corner(Vector2i(index.x + 1, index.y + 1))
	var center = (top_left + bottom_right) / 2
	
	var end = center + Dir.to_vector(dir) * (bottom_right.x - center.x)
	var start = (center - end) / 4 + end
	draw_dashed_line(start, end, Color.CADET_BLUE, 4.0)


# really stupid approach, but im lazy
func first_visible_x() -> int:
	var x = 0
	while true:
		var index = Vector2i(x, 0)
		var top_left = top_left_corner(index)
		if top_left.x > 0:
			break
		else:
			x += 1
	return x

func first_visible_y() -> int:
	var y = 0
	while true:
		var index = Vector2i(0, y)
		var top_left = top_left_corner(index)
		if top_left.y > 0:
			break
		else:
			y += 1
	return y

func draw_sliced_placeholder_square(index: Vector2i, bound: Vector2, type) -> void:
	var top_left = top_left_corner(index)
	if top_left.x < 0:
		top_left.x = bound.x
	if top_left.y < 0:
		top_left.y = bound.y
	var bottom_right = top_left_corner(Vector2i(index.x + 1, index.y + 1))
	var color = placeholder_color(type)
	draw_rect(Rect2(top_left, bottom_right - top_left), color)

func draw_placeholder_square(index: Vector2i, type) -> void:
	var top_left = top_left_corner(index)
	var color = placeholder_color(type)
	draw_square(top_left, draw_scale * GRID_SIZE, color)

func placeholder_color(type) -> Color:
	match layer:
		ShipBlueprintDesigner.Layer.STRUCTURE:
			match type:
				StructureBlueprint.Type.EMPTY:
					return Color.BLACK
				StructureBlueprint.Type.DEBUG:
					return Color.WHITE
		ShipBlueprintDesigner.Layer.FACTORY:
			match type:
				FactoryPartBlueprint.Type.EMPTY:
					return Color.BLACK
				FactoryPartBlueprint.Type.DEBUG:
					return Color.WHITE
				FactoryPartBlueprint.Type.THRUSTER:
					return Color.RED
				FactoryPartBlueprint.Type.GUN:
					return Color.GREEN
	return Color(0, 0, 0, 0)

func draw_square(top_left: Vector2, side_length: float, color: Color) -> void:
	draw_rect(Rect2(top_left, Vector2(side_length, side_length)), color)

func top_left_or_zero(index: Vector2i) -> Vector2:
	var top_left = top_left_corner(index)
	if top_left.x < 0:
		top_left.x = 0
	if top_left.y < 0:
		top_left.y = 0
	return top_left

func top_left_corner(index: Vector2i) -> Vector2:
	return draw_scale * Vector2(index.x * GRID_SIZE, index.y * GRID_SIZE) + offset

func index_at(pos: Vector2) -> Vector2i:
	var index_float = (pos - offset) / (draw_scale * GRID_SIZE)
	return Vector2i(floor(index_float.x), floor(index_float.y))