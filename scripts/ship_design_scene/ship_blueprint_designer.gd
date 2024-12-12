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

const EXPECTED_RATIO = 16.0 / 9.0
const H_SPLIT = 0.2
var layer_selector_top_left: UICoord = UICoord.new(Vector2(H_SPLIT, 0.0), self)
var layer_selector_bottom_right: UICoord = UICoord.new(Vector2(1.0, 0.03), self)

var tool_palette_top_left: UICoord = UICoord.new(Vector2(H_SPLIT, 0.03), self)
var tool_palette_bottom_right: UICoord = UICoord.new(Vector2(1.0, 0.25), self)

var grid_top_left: UICoord = UICoord.new(Vector2(H_SPLIT, 0.25), self)
var grid_bottom_right: UICoord = UICoord.new(Vector2(1.0, 1.0), self)

var test_button_top_left: UICoord = UICoord.new(Vector2(0.0, 0.0), self)
var test_button_bottom_right: UICoord = UICoord.new(Vector2(H_SPLIT, 0.1), self)

var save_button_top_left: UICoord = UICoord.new(Vector2(0.0, 0.1), self)
var save_button_bottom_right: UICoord = UICoord.new(Vector2(H_SPLIT / 2, 0.15), self)

var load_button_top_left: UICoord = UICoord.new(Vector2(H_SPLIT / 2, 0.1), self)
var load_button_bottom_right: UICoord = UICoord.new(Vector2(H_SPLIT, 0.15), self)

const BOX_WIDTH = H_SPLIT
const BOX_HEIGHT = H_SPLIT * EXPECTED_RATIO
var action_binder_top_left = UICoord.new(Vector2(0.0, 1 - BOX_HEIGHT - 0.1), self)
var action_binder_bottom_right = UICoord.new(Vector2(H_SPLIT, 1 - BOX_HEIGHT), self)

var config_panel_top_left: UICoord = UICoord.new(Vector2(0.0, 1 - BOX_HEIGHT), self)
var config_panel_bottom_right: UICoord = UICoord.new(Vector2(H_SPLIT, 1.0), self)

enum Layer {STRUCTURE, FACTORY}

var editor: BlueprintEditor
var writer: BlueprintWriter
var reader: BlueprintReader

var layer_selector: LayerSelector
var palette: ToolPalette
var grid: BlueprintGrid

var test_button: TestButton
var binder: BlueprintActionBinder
var config: ConfigPanel

@onready var save_dialog = $SaveDialog
@onready var load_dialog = $LoadDialog

# needs to exist for the none tool
func do_nothing(_index: Vector2i) -> void:
	pass

func place_module(index: Vector2i) -> void:
	var current = palette.selected_type()
	editor.set_structure_type(index, current)
	editor.set_adjacent_connections(index, true)

func remove_module(index: Vector2i) -> void:
	editor.set_adjacent_connections(index, false)
	editor.set_structure_type(index, StructureBlueprint.Type.EMPTY)

func place_part(index: Vector2i) -> void:
	var current = palette.selected_type()
	editor.set_part_type(index, current)

func remove_part(index: Vector2i) -> void:
	editor.set_part_type(index, FactoryPartBlueprint.Type.EMPTY)

func configure_select(index: Vector2i) -> void:
	config.select(index)

var tool_actions: Array[Callable] = [Callable(do_nothing),
									 Callable(place_module),
									 Callable(remove_module),
									 Callable(place_part),
									 Callable(remove_part),
									 Callable(configure_select)]

func _init() -> void:
	var blueprint = ShipGridBlueprint.blank(10, 10)

	editor = BlueprintEditor.new(blueprint)
	writer = BlueprintWriter.new()
	reader = BlueprintReader.new()

	layer_selector = LayerSelector.new()
	grid = BlueprintGrid.new(editor)
	palette = ToolPalette.new()
	test_button = TestButton.new(blueprint)
	binder = BlueprintActionBinder.new(editor)
	config = ConfigPanel.new(editor)

func _ready() -> void:
	layer_selector.position = layer_selector_top_left.to_px()
	palette.position = tool_palette_top_left.to_px()
	grid.position = grid_top_left.to_px()

	test_button.position = test_button_top_left.to_px()
	binder.position = action_binder_top_left.to_px()
	config.position = config_panel_top_left.to_px()

	add_child(layer_selector)
	add_child(palette)
	add_child(grid)

	add_child(test_button)
	add_child(binder)
	add_child(config)
	
	# Create Save Button
	var save_button = Button.new()
	save_button.text = "Save"
	save_button.position = save_button_top_left.to_px()
	save_button.size = save_button_bottom_right.to_px() - save_button_top_left.to_px()
	save_button.connect("pressed", Callable(self, "_on_save_button_pressed"))
	add_child(save_button)

	# Create Load Button
	var load_button = Button.new()
	load_button.text = "Load"
	load_button.position = load_button_top_left.to_px()
	load_button.size = load_button_bottom_right.to_px() - load_button_top_left.to_px()
	load_button.connect("pressed", Callable(self, "_on_load_button_pressed"))
	add_child(load_button)
	
	# Save Dialog configuration
	load_dialog.current_dir = "res://"
	load_dialog.visible = false
	
	# Load Dialog configuration
	load_dialog.current_dir = "res://"
	load_dialog.visible = false

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

	test_button.position = test_button_top_left.to_px()
	test_button.width = test_button_bottom_right.to_px().x - test_button_top_left.to_px().x
	test_button.height = test_button_bottom_right.to_px().y - test_button_top_left.to_px().y

	binder.position = action_binder_top_left.to_px()
	binder.width = action_binder_bottom_right.to_px().x - action_binder_top_left.to_px().x
	binder.height = action_binder_bottom_right.to_px().y - action_binder_top_left.to_px().y

	config.position = config_panel_top_left.to_px()
	config.width = config_panel_bottom_right.to_px().x - config_panel_top_left.to_px().x
	config.height = config_panel_bottom_right.to_px().y - config_panel_top_left.to_px().y


	# tell the grid and the config which layer is selected
	grid.layer = layer_selector.selected
	config.layer = layer_selector.selected
	palette.layer = layer_selector.selected
	binder.layer = layer_selector.selected

	# tell the grid which position is being configured
	if config.is_selected:
		grid.select(config.selected)
	else:
		grid.deselect()
	
	# tell the action binder which position is being configured
	if config.is_selected:
		binder.select(config.selected)
	else:
		binder.deselect()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_MIDDLE:
			match mouse_event.pressed:
				true:
					start_drag_on_self(event.position)
				false:
					end_drag_on_self(event.position)
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_up_on_self(event.position)
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_down_on_self(event.position)
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT && mouse_event.pressed:
			click_on_self(event.position)

	if event is InputEventMouseMotion:
		var mouse_event = event as InputEventMouseMotion
		move_on_self(event.position, mouse_event.relative)
	
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.pressed:
			key_on_self(get_global_mouse_position(), key_event.keycode)

func key_on_self(pos: Vector2, scancode: int) -> void:
	var binder_rect = Rect2(binder.position, Vector2(binder.width, binder.height))
	var is_on_binder: bool = binder_rect.has_point(pos)
	if is_on_binder:
		binder.set_keybind(scancode)

func move_on_self(pos: Vector2, relative: Vector2) -> void:
	if is_on_grid(pos) and grid.dragging:
		grid.drag_by(relative)


func start_drag_on_self(pos: Vector2) -> void:
	if is_on_grid(pos):
		grid.start_drag()

func end_drag_on_self(_pos: Vector2) -> void:
	# note that we don't want to check bounds here because we want to end the drag when the mouse exits
	# the confines of the grid
	grid.end_drag()

func scroll_up_on_self(pos: Vector2) -> void:
	if is_on_grid(pos):
		grid.zoom_in()

func scroll_down_on_self(pos: Vector2) -> void:
	if is_on_grid(pos):
		grid.zoom_out()

func click_on_self(pos: Vector2) -> void:
	var layer_selector_rect = Rect2(layer_selector.position, Vector2(layer_selector.width, layer_selector.height))
	var palette_rect = Rect2(palette.position, Vector2(palette.width, palette.height))
	var grid_rect = Rect2(grid.position, Vector2(grid.width, grid.height))
	var config_rect = Rect2(config.position, Vector2(config.width, config.height))
	var test_button_rect = Rect2(test_button.position, Vector2(test_button.width, test_button.height))
	var binder_rect = Rect2(binder.position, Vector2(binder.width, binder.height))

	var on_layer_selector: bool = layer_selector_rect.has_point(pos)
	var on_palette: bool = palette_rect.has_point(pos)
	var on_grid: bool = grid_rect.has_point(pos)
	var on_config: bool = config_rect.has_point(pos)
	var on_test_button: bool = test_button_rect.has_point(pos)
	var on_binder: bool = binder_rect.has_point(pos)

	if on_layer_selector:
		layer_selector.select_at(pos - layer_selector.position)
	elif on_palette:
		palette.select_at(pos - palette.position)
	elif on_grid:
		tool_actions[ToolPalette.type(palette.selected, layer_selector.selected)].call(grid.index_at(pos - grid.position))
	elif on_config:
		config.click_at(pos - config.position)
	elif on_test_button:
		test_button.click()

		
	elif on_binder:
		binder.click_at(pos - binder.position)

func is_on_grid(pos: Vector2) -> bool:
	return Rect2(grid.position, Vector2(grid.width, grid.height)).has_point(pos)

func save_blueprint(file_path: String) -> void:
	if writer == null or editor == null:
		print("Writer or Editor not initialized!")
		return
	print("Saving blueprint to:", file_path)
	# print(editor.blueprint.print_as_string())
	writer.save_ship_grid_to_json(editor.blueprint, file_path)

func load_blueprint(file_path: String) -> void:
	if reader == null or editor == null:
		print("Reader or Editor not initialized!")
		return
	print("Loading blueprint from:", file_path)
	var loaded_blueprint = reader.load_ship_grid_from_json(file_path)
	if loaded_blueprint == null:
		print("Failed to load blueprint.")
		return
	editor.set_blueprint(loaded_blueprint)
	print("Blueprint loaded successfully.")
	
func _on_save_button_pressed() -> void:
	save_dialog.visible = true
	save_dialog.popup_centered()
	#var file_path = "res://test_blueprint.json"  # Save to the user directory
	#save_blueprint(file_path)

func _on_load_button_pressed() -> void:
	load_dialog.visible = true
	load_dialog.popup_centered()
	#var file_path = "res://test_blueprint.json"  # Load from the user directory
	#load_blueprint(file_path)

func _on_load_dialog_file_selected(path: String) -> void:
	load_blueprint(path)
	print(path, " successfully sent to load_blueprint.")

func _on_save_dialog_file_selected(path: String) -> void:
	save_blueprint(path)
	print(path, " successfully sent to save_blueprint.")
