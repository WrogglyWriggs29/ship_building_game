class_name ShipBlueprintDesigner
extends Node2D

# For defining UI layout, a normalized coordinate system is used between 0 and 1
# This then gets stretched to the viewport size
class UICoord:
	var coord: Vector2
	var parent: Node2D
	func _init(_coord: Vector2, _parent: Node2D) -> void:
		coord = _coord
		parent = _parent
	
	func to_px() -> Vector2:
		var size = parent.get_viewport().size
		return Vector2(coord.x * size.x, coord.y * size.y)

var grid_top_left: UICoord = UICoord.new(Vector2(0.2, 0.2), self)
var grid_bottom_right: UICoord = UICoord.new(Vector2(1.0, 1.0), self)
var tool_palette_top_left: UICoord = UICoord.new(Vector2(0.2, 0.05), self)
var tool_palette_bottom_right: UICoord = UICoord.new(Vector2(1.0, 0.2), self)

enum Layer {STRUCTURE, FACTORY}

var editor: BlueprintEditor
var grid: BlueprintGrid
var palette: ToolPalette

func place_module(index: Vector2i) -> void:
	var current = StructureBlueprint.Type.DEBUG # palette.selected_module_type()
	editor.set_type(index, current)

func remove_module(index: Vector2i) -> void:
	editor.set_type(index, StructureBlueprint.Type.EMPTY)

var tool_actions: Array[Callable] = [Callable(place_module), Callable(remove_module)]

func _init() -> void:
	var blueprint = ShipGridBlueprint.blank(10, 10)
	editor = BlueprintEditor.new(blueprint)
	grid = BlueprintGrid.new(editor)
	palette = ToolPalette.new()

func _ready() -> void:
	grid.position = grid_top_left.to_px()
	palette.position = tool_palette_top_left.to_px()
	add_child(grid)
	add_child(palette)

func _process(_delta: float) -> void:
	grid.position = grid_top_left.to_px()
	palette.position = tool_palette_top_left.to_px()
	palette.width = tool_palette_bottom_right.to_px().x - tool_palette_top_left.to_px().x
	palette.height = tool_palette_bottom_right.to_px().y - tool_palette_top_left.to_px().y

func _input(event: InputEvent) -> void:
	var on_grid: bool = event.position.x > grid.position.x and event.position.y > grid.position.y
	var on_palette: bool = not on_grid and event.position.x > palette.position.x and event.position.y > palette.position.y

	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_MIDDLE:
			match mouse_event.pressed:
				true:
					if on_grid:
						grid.start_drag()
				false:
					grid.end_drag()
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP && on_grid:
			grid.zoom_in()
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN && on_grid:
			grid.zoom_out()
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if on_palette:
				palette.select_at(mouse_event.position - palette.position)
			elif on_grid:
				tool_actions[palette.selected].call(grid.index_at(mouse_event.position - grid.position))

	if event is InputEventMouseMotion:
		if on_grid:
			var mouse_event = event as InputEventMouseMotion
			if grid.dragging:
				grid.drag_by(mouse_event.relative)
