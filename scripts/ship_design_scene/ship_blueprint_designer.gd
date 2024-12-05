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

var layer_selector_top_left: UICoord = UICoord.new(Vector2(0.2, 0.0), self)
var layer_selector_bottom_right: UICoord = UICoord.new(Vector2(1.0, 0.03), self)
var tool_palette_top_left: UICoord = UICoord.new(Vector2(0.2, 0.03), self)
var tool_palette_bottom_right: UICoord = UICoord.new(Vector2(1.0, 0.2), self)
var grid_top_left: UICoord = UICoord.new(Vector2(0.2, 0.2), self)
var grid_bottom_right: UICoord = UICoord.new(Vector2(1.0, 1.0), self)

enum Layer {STRUCTURE, FACTORY}

var editor: BlueprintEditor
var layer_selector: LayerSelector
var palette: ToolPalette
var grid: BlueprintGrid

# needs to exist for the none tool
func do_nothing(_index: Vector2i) -> void:
	pass

func place_module(index: Vector2i) -> void:
	var current = StructureBlueprint.Type.DEBUG # palette.selected_module_type()
	editor.set_structure_type(index, current)

func remove_module(index: Vector2i) -> void:
	editor.set_structure_type(index, StructureBlueprint.Type.EMPTY)

func place_part(index: Vector2i) -> void:
	var current = FactoryPartBlueprint.Type.DEBUG # palette.selected_module_type()
	editor.set_part_type(index, current)

func remove_part(index: Vector2i) -> void:
	editor.set_part_type(index, FactoryPartBlueprint.Type.EMPTY)

var tool_actions: Array[Callable] = [Callable(do_nothing), Callable(place_module), Callable(remove_module), Callable(place_part), Callable(remove_part)]

func _init() -> void:
	var blueprint = ShipGridBlueprint.blank(10, 10)
	editor = BlueprintEditor.new(blueprint)
	layer_selector = LayerSelector.new()
	grid = BlueprintGrid.new(editor)
	palette = ToolPalette.new()

func _ready() -> void:
	layer_selector.position = layer_selector_top_left.to_px()
	palette.position = tool_palette_top_left.to_px()
	grid.position = grid_top_left.to_px()
	add_child(layer_selector)
	add_child(palette)
	add_child(grid)

func _process(_delta: float) -> void:
	layer_selector.position = layer_selector_top_left.to_px()
	layer_selector.width = layer_selector_bottom_right.to_px().x - layer_selector_top_left.to_px().x
	layer_selector.height = layer_selector_bottom_right.to_px().y - layer_selector_top_left.to_px().y

	palette.position = tool_palette_top_left.to_px()
	palette.width = tool_palette_bottom_right.to_px().x - tool_palette_top_left.to_px().x
	palette.height = tool_palette_bottom_right.to_px().y - tool_palette_top_left.to_px().y

	grid.position = grid_top_left.to_px()
	grid.width = grid_bottom_right.to_px().x - grid_top_left.to_px().x
	grid.height = grid_bottom_right.to_px().y - grid_top_left.to_px().y

	grid.layer = layer_selector.selected

func _input(event: InputEvent) -> void:
	var layer_selector_rect = Rect2(layer_selector.position, Vector2(layer_selector.width, layer_selector.height))
	var palette_rect = Rect2(palette.position, Vector2(palette.width, palette.height))
	var grid_rect = Rect2(grid.position, Vector2(grid.width, grid.height))

	var on_layer_selector: bool = layer_selector_rect.has_point(event.position)
	var on_palette: bool = palette_rect.has_point(event.position)
	var on_grid: bool = grid_rect.has_point(event.position)

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
			if on_layer_selector:
				layer_selector.select_at(mouse_event.position - layer_selector.position)
			elif on_palette:
				palette.select_at(mouse_event.position - palette.position)
			elif on_grid:
				tool_actions[ToolPalette.type(palette.selected, layer_selector.selected)].call(grid.index_at(mouse_event.position - grid.position))

	if event is InputEventMouseMotion:
		if on_grid:
			var mouse_event = event as InputEventMouseMotion
			if grid.dragging:
				grid.drag_by(mouse_event.relative)
