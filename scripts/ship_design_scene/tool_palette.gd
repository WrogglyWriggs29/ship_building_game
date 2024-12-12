class_name ToolPalette
extends Node2D

# The part of the ship designer scene that allows tool (and tool parameter) selection

enum ToolType {NONE, PLACE_STRUCTURE, REMOVE_STRUCTURE, PLACE_FACTORY, REMOVE_FACTORY, CONFIGURE_SELECT}

const TYPE_SELECTION_HEIGHT = 1.0 / 5.0

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


var tool_sel_options: SelectionOptions = SelectionOptions.new()
var s_type_sel_options: SelectionOptions = SelectionOptions.new()
var p_type_sel_options: SelectionOptions = SelectionOptions.new()

var selected: int = 0
var type_selected: int = 0

var width: float
var height: float

var layer: ShipBlueprintDesigner.Layer

var tool_placeholder_text = ["Place", "Remove", "Select"]

var structure_type_placeholder_text = ["Debug"]
var part_type_placeholder_text = ["Debug", "Thruster"]

func _process(_delta: float) -> void:
	if width == 0 or height == 0:
		return
	if height > width:
		return
	
	var tool_height = height * (1 - TYPE_SELECTION_HEIGHT)
	var type_height = height * TYPE_SELECTION_HEIGHT

	var cell_size = Vector2(min(width / tool_placeholder_text.size(), tool_height), tool_height)
	var sub_cell_size = Vector2(cell_size.x, type_height)

	tool_sel_options.clear()
	for i in range(tool_placeholder_text.size()):
		var rect = Rect2(Vector2(i * cell_size.x, 0), cell_size)
		tool_sel_options.push(rect)
	
	s_type_sel_options.clear()
	for i in range(structure_type_placeholder_text.size()):
		var rect = Rect2(Vector2(i * sub_cell_size.x, tool_height), sub_cell_size)
		s_type_sel_options.push(rect)
	
	p_type_sel_options.clear()
	for i in range(part_type_placeholder_text.size()):
		var rect = Rect2(Vector2(i * sub_cell_size.x, tool_height), sub_cell_size)
		p_type_sel_options.push(rect)

	queue_redraw()

func _draw() -> void:
	for i in tool_sel_options.count():
		var rect = tool_sel_options.at(i)
		if i == selected:
			var color = Color.CADET_BLUE
			draw_rect(rect, color)
		draw_line(rect.position, rect.position + Vector2(0, rect.size.y), Color.BLACK)
		draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + rect.size.x / 4, rect.position.y + rect.size.y / 2), tool_placeholder_text[i])
	
	if tool_sel_options.count() > 0:
		var end = tool_sel_options.at(tool_sel_options.count() - 1)
		draw_line(end.position + Vector2(end.size.x, 0), end.position + end.size, Color.BLACK)


	match selected:
		0:
			draw_type_selection()

	draw_line(Vector2(0, 0), Vector2(width, 0), Color.BLACK)
	var tool_height = height * (1 - TYPE_SELECTION_HEIGHT)
	draw_line(Vector2(0, tool_height), Vector2(width, tool_height), Color.BLACK)
	draw_line(Vector2(0, height), Vector2(width, height), Color.BLACK)

func selected_type() -> int:
	if selected != 0:
		return 0
	else:
		return type_selected + 1
	

func draw_type_selection() -> void:
	match layer:
		ShipBlueprintDesigner.Layer.STRUCTURE:
			for i in s_type_sel_options.count():
				var rect = s_type_sel_options.at(i)
				if i == type_selected:
					var color = Color.CADET_BLUE
					draw_rect(rect, color)
				draw_line(rect.position, rect.position + Vector2(0, rect.size.y), Color.BLACK)
				draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + rect.size.x / 4, rect.position.y + rect.size.y / 1.5), structure_type_placeholder_text[i])
			
			if s_type_sel_options.count() > 0:
				var end = s_type_sel_options.at(s_type_sel_options.count() - 1)
				draw_line(end.position + Vector2(end.size.x, 0), end.position + end.size, Color.BLACK)
		ShipBlueprintDesigner.Layer.FACTORY:
			for i in p_type_sel_options.count():
				var rect = p_type_sel_options.at(i)
				if i == type_selected:
					var color = Color.CADET_BLUE
					draw_rect(rect, color)
				draw_line(rect.position, rect.position + Vector2(0, rect.size.y), Color.BLACK)
				draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + rect.size.x / 4, rect.position.y + rect.size.y / 1.5), part_type_placeholder_text[i])
			
			if p_type_sel_options.count() > 0:
				var end = p_type_sel_options.at(p_type_sel_options.count() - 1)
				draw_line(end.position + Vector2(end.size.x, 0), end.position + end.size, Color.BLACK)


func select_at(point: Vector2) -> void:
	var tool_index = tool_sel_options.check_selected(point)
	var type_index = -1
	match layer:
		ShipBlueprintDesigner.Layer.STRUCTURE:
			type_index = s_type_sel_options.check_selected(point)
		ShipBlueprintDesigner.Layer.FACTORY:
			type_index = p_type_sel_options.check_selected(point)
	if tool_index != -1:
		selected = tool_index
		queue_redraw()
	elif type_index != -1:
		type_selected = type_index
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