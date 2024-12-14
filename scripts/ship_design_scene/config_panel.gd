class_name ConfigPanel
extends Node2D

var width: float
var height: float

var editor: BlueprintEditor

var is_selected: bool = false
var selected: Vector2i

var layer: ShipBlueprintDesigner.Layer = ShipBlueprintDesigner.Layer.STRUCTURE

func _init(_editor: BlueprintEditor) -> void:
	editor = _editor

func _process(_delta: float) -> void:
	if width <= 0 or height <= 0:
		return
	
	match layer:
		ShipBlueprintDesigner.Layer.STRUCTURE:
			var type = editor.read_structure_type(selected)
			if type == StructureBlueprint.Type.EMPTY:
				deselect()
		ShipBlueprintDesigner.Layer.FACTORY:
			var type = editor.read_part_type(selected)
			if type == FactoryPartBlueprint.Type.EMPTY:
				deselect()

	queue_redraw()

func _draw() -> void:
	# border
	draw_line(Vector2(0, 0), Vector2(width, 0), Color.BLACK)
	draw_line(Vector2(0, height), Vector2(width, height), Color.BLACK)
	draw_line(Vector2(0, 0), Vector2(0, height), Color.BLACK)
	draw_line(Vector2(width, 0), Vector2(width, height), Color.BLACK)

	if is_selected:
		match layer:
			ShipBlueprintDesigner.Layer.STRUCTURE:
				draw_structure_config()
			ShipBlueprintDesigner.Layer.FACTORY:
				draw_factory_config()
	else:
		draw_string(ThemeDB.fallback_font, Vector2(5, 15), "Nothing is selected...")

func draw_structure_config() -> void:
	var center = Vector2(width / 2, height / 2)
	var radius = width / 10
	draw_circle(center, radius, Color.WHITE_SMOKE)

	for dir in Dir.MAX:
		var connection_value = editor.read_connection(selected, dir)
		var color = Color.CADET_BLUE if connection_value else Color.INDIAN_RED
		draw_trait_display_arrow(dir, color, false)
		
		draw_rect(direction_selection_rect(dir), Color.RED, false)

	var type = editor.read_structure_type(selected)
	var type_name = StructureBlueprint.type_name(type)
	draw_string(ThemeDB.fallback_font, Vector2(5, 15), "Configure " + type_name)

func draw_factory_config() -> void:
	var center = Vector2(width / 2, height / 2)
	var radius = width / 10
	draw_circle(center, radius, Color.WHITE_SMOKE)

	var type = editor.read_part_type(selected)
	var type_name = FactoryPartBlueprint.type_name(type)
	var orientation = editor.read_part_orientation(selected)

	# for thrusters, we want the arrow to show as pushing the point in the direction of the arrow
	orientation = Dir.reverse(orientation) if type == FactoryPartBlueprint.Type.THRUSTER else orientation
	var reverse = (type == FactoryPartBlueprint.Type.THRUSTER)

	draw_trait_display_arrow(orientation, Color.CADET_BLUE, reverse)

	for dir in Dir.MAX:
		draw_rect(direction_selection_rect(dir), Color.RED, false)

	draw_string(ThemeDB.fallback_font, Vector2(5, 15), "Configure " + type_name)

func draw_trait_display_arrow(dir: int, color: Color, reverse: bool) -> void:
	var center = Vector2(width / 2, height / 2)
	var radius = width / 10
	var arrow_length = width / 2 - radius - width / 10
	var dir_vector = Dir.to_vector(dir)
	var offset = dir_vector * (radius + width / 20)

	match reverse:
		true:
			var true_offset = offset + dir_vector * arrow_length
			draw_arrow(center + true_offset, -dir_vector, arrow_length, color)
		false:
			draw_arrow(center + offset, dir_vector, arrow_length, color)

func select(index: Vector2i) -> void:
	selected = index
	is_selected = true

func deselect() -> void:
	is_selected = false

func click_at(pos: Vector2) -> void:
	if not is_selected:
		return

	match layer:
		ShipBlueprintDesigner.Layer.STRUCTURE:
			for dir in Dir.MAX:
				if direction_selection_rect(dir).has_point(pos):
					editor.flip_connection_bools(selected, dir)
					return
		ShipBlueprintDesigner.Layer.FACTORY:
			for dir in Dir.MAX:
				if direction_selection_rect(dir).has_point(pos):
					match editor.read_part_type(selected):
						FactoryPartBlueprint.Type.THRUSTER:
							editor.set_part_orientation(selected, Dir.reverse(dir))
						_:
							editor.set_part_orientation(selected, dir)
					return
	

func direction_selection_rect(dir: int) -> Rect2:
	var center = Vector2(width / 2, height / 2)
	var offset = width / 10 + width / 20

	var rect_width = width / 4
	var rect_height = width / 2 - width / 5

	var top_left = center + Vector2(0, -offset) + Vector2(-rect_width / 2, -rect_height)
	var default_rect = Rect2(top_left, Vector2(rect_width, rect_height))

	var dir_vector = Dir.to_vector(dir)
	var rotation_angle = dir_vector.angle_to(Vector2(0, -1))
	var transform = Transform2D(rotation_angle, center)

	var transformed = default_rect * transform
	transformed.position += center

	return transformed


func draw_arrow(start: Vector2, dir: Vector2, length: float, color: Color) -> void:
	var column_width = length / 3
	var head_width = column_width * 2
	var head_length = length / 3

	var polygon = []
	polygon.push_back(start)
	var br_point = start + dir.rotated(PI / 2) * column_width / 2
	polygon.push_back(br_point)
	var tr_point = br_point + dir * length - dir * head_length
	polygon.push_back(tr_point)
	var head_point_r = tr_point + dir.rotated(PI / 2) * (head_width - column_width) / 2
	polygon.push_back(head_point_r)
	var head_point = start + dir * length
	polygon.push_back(head_point)
	var head_point_l = head_point_r + dir.rotated(-PI / 2) * head_width
	polygon.push_back(head_point_l)
	var tl_point = tr_point + dir.rotated(-PI / 2) * column_width
	polygon.push_back(tl_point)
	var bl_point = start + dir.rotated(-PI / 2) * column_width / 2
	polygon.push_back(bl_point)
	polygon.push_back(start)
	#polygon.append(tr_point)
	#polygon.append(start)
	#polygon.append(start + dir.rotated(PI / 2) * column_width / 2 + dir * length - dir * head_length)
	#polygon.append(start + dir.rotated(PI / 2) * column_width / 2 + dir * length - dir * head_length + dir.rotated(PI / 4) * head_width)
	draw_colored_polygon(PackedVector2Array(polygon), color)
