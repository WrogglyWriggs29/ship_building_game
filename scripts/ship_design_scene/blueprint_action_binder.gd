class_name BlueprintActionBinder
extends Node2D

var editor: BlueprintEditor
var width: float
var height: float
var layer: ShipBlueprintDesigner.Layer

var is_selected: bool = false
var selected: Vector2i = Vector2i.ZERO

func _init(_editor: BlueprintEditor) -> void:
	editor = _editor

func _process(_delta: float) -> void:
	if width <= 0 or height <= 0:
		return
	
	queue_redraw()

func _draw() -> void:
	const TEXT_OFFSET = Vector2(5, 20)
	if is_selected:
		var action = action_string()

		if action == "":
			draw_string(ThemeDB.fallback_font, TEXT_OFFSET, "Nothing to do...")
		else:
			var current = editor.read_keybind(selected)
			var keybind = "None" if current == -1 else OS.get_keycode_string(current)
			draw_string(ThemeDB.fallback_font, TEXT_OFFSET, "Set Keybind for " + action)
			draw_string(ThemeDB.fallback_font, TEXT_OFFSET + Vector2(0, 15), "<" + keybind + ">")
	else:
		draw_string(ThemeDB.fallback_font, TEXT_OFFSET, "Nothing is selected...")
	
	draw_line(Vector2(0, 0), Vector2(width, 0), Color.BLACK)
	draw_line(Vector2(0, height), Vector2(width, height), Color.BLACK)
	
func select(pos: Vector2) -> void:
	is_selected = true
	selected = pos

func deselect() -> void:
	is_selected = false
	selected = Vector2i.ZERO

func set_keybind(key: int) -> void:
	if is_selected:
		editor.set_keybind(selected, key)

func action_string() -> String:
	match layer:
		ShipBlueprintDesigner.Layer.STRUCTURE:
			match editor.read_structure_type(selected):
				StructureBlueprint.Type.EMPTY:
					return ""
				_:
					return ""
		ShipBlueprintDesigner.Layer.FACTORY:
			match editor.read_part_type(selected):
				FactoryPartBlueprint.Type.EMPTY:
					return ""
				FactoryPartBlueprint.Type.DEBUG:
					return ""
				FactoryPartBlueprint.Type.THRUSTER:
					return "Burn"
				_:
					return ""
		_:
			return ""
