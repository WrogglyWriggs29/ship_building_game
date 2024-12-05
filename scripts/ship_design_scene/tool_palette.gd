class_name ToolPalette
extends Node2D

# The part of the ship designer scene that allows tool (and tool parameter) selection

enum ToolType {NONE, PLACE_STRUCTURE, REMOVE_STRUCTURE, PLACE_FACTORY, REMOVE_FACTORY, CONFIGURE_SELECT}

class SelectionOptions:
	var options: Array[Rect2]

	func _init() -> void:
		options = []
	
	func check_selected(point: Vector2) -> int:
		for i in range(options.size()):
			if options[i].has_point(point):
				return i
		return -1
	
	func clear() -> void:
		options.clear()

	func push(rect: Rect2) -> void:
		options.push_back(rect)
	
	func count() -> int:
		return options.size()
	
	func at(index: int) -> Rect2:
		return options[index]


var sel_options: SelectionOptions = SelectionOptions.new()

var selected: int = 0

var width: float
var height: float

var placeholder_text = ["Place", "Remove", "Select"]

func _process(_delta: float) -> void:
	if width == 0 or height == 0:
		return
	if height > width:
		return
	

	var cell_size = Vector2(min(width / placeholder_text.size(), height), height)

	sel_options.clear()
	for i in range(placeholder_text.size()):
		var rect = Rect2(Vector2(i * cell_size.x, 0), cell_size)
		sel_options.push(rect)

	queue_redraw()

func _draw() -> void:
	for i in sel_options.count():
		var rect = sel_options.at(i)
		if i == selected:
			var color = Color.CADET_BLUE
			draw_rect(rect, color)
		draw_line(rect.position, rect.position + Vector2(0, rect.size.y), Color.BLACK)
		draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + rect.size.x / 4, rect.position.y + rect.size.y / 2), placeholder_text[i])
	
	if sel_options.count() > 0:
		var end = sel_options.at(sel_options.count() - 1)
		draw_line(end.position + Vector2(end.size.x, 0), end.position + end.size, Color.BLACK)

	draw_line(Vector2(0, 0), Vector2(width, 0), Color.BLACK)
	draw_line(Vector2(0, height), Vector2(width, height), Color.BLACK)

func select_at(point: Vector2) -> void:
	var index = sel_options.check_selected(point)
	if index != -1:
		selected = index
		queue_redraw()

static func type(index: int, _layer: ShipBlueprintDesigner.Layer) -> ToolType:
	match _layer:
		ShipBlueprintDesigner.Layer.STRUCTURE:
			match index:
				0:
					return ToolType.PLACE_STRUCTURE
				1:
					return ToolType.REMOVE_STRUCTURE
		ShipBlueprintDesigner.Layer.FACTORY:
			match index:
				0:
					return ToolType.PLACE_FACTORY
				1:
					return ToolType.REMOVE_FACTORY
	
	match index:
		2:
			return ToolType.CONFIGURE_SELECT
	
	return ToolType.NONE
