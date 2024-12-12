class_name PlayerSelector
extends Node2D

var width: float
var height: float
var player_num: int
var selected_index: int = 0
var blueprints: Array[ShipGridBlueprint] = []
var blueprint_names: Array[String] = []


const BlueprintReader = preload("res://scripts/blueprints/blueprint_reader.gd")


func _init(_player_num: int) -> void:
	player_num = _player_num

func _process(_delta: float) -> void:
	if width <= 0 or height <= 0:
		return
	queue_redraw()

func _draw() -> void:
	# Draw player label
	var label = "Player " + str(player_num)
	draw_string(ThemeDB.fallback_font, Vector2(10, 30), label)
	
	# Draw selection box
	var box_rect = Rect2(10, 40, width - 20, height - 50)
	draw_rect(box_rect, Color.DARK_GRAY)
	
	# Draw blueprint list
	for i in range(blueprint_names.size()):
		var y_pos = 60 + i * 30
		var color = Color.CADET_BLUE if i == selected_index else Color.WHITE
		draw_string(ThemeDB.fallback_font, Vector2(20, y_pos), blueprint_names[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)

func load_blueprints(dir_path: String) -> void:
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".blueprint"):
				var blueprint = BlueprintReader.read_file(dir_path + file_name)
				if blueprint:
					blueprints.append(blueprint)
					blueprint_names.append(file_name.get_basename())
					print("Loaded blueprint: ", file_name, " (", blueprint.width, "x", blueprint.height, ")")
			file_name = dir.get_next()

func get_selected_blueprint() -> ShipGridBlueprint:
	if blueprints.size() > 0:
		return blueprints[selected_index]
	return null

func handle_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match player_num:
			1:  # Player 1 controls: W/S
				if event.keycode == KEY_W and selected_index > 0:
					selected_index -= 1
					queue_redraw()
				elif event.keycode == KEY_S and selected_index < blueprint_names.size() - 1:
					selected_index += 1
					queue_redraw()
			2:  # Player 2 controls: Up/Down arrows
				if event.keycode == KEY_UP and selected_index > 0:
					selected_index -= 1
					queue_redraw()
				elif event.keycode == KEY_DOWN and selected_index < blueprint_names.size() - 1:
					selected_index += 1
					queue_redraw()
