class_name TestButton
extends Node2D

const TEST_SCENE_FILE = "res://ship_test_level.tscn"

var width: float
var height: float

var blueprint: ShipGridBlueprint

func _init(_blueprint: ShipGridBlueprint) -> void:
	blueprint = _blueprint

func _process(_delta: float) -> void:
	if width <= 0 or height <= 0:
		return
	queue_redraw()

func _draw() -> void:
	var button_rect = Rect2(Vector2.ZERO, Vector2(width, height))

	# draw fill
	draw_rect(button_rect, Color.INDIAN_RED)

	# draw borders
	draw_line(Vector2.ZERO, Vector2(width, 0), Color.BLACK)
	draw_line(Vector2(0, height), Vector2(width, height), Color.BLACK)
	draw_line(Vector2.ZERO, Vector2(0, height), Color.BLACK)
	draw_line(Vector2(width, 0), Vector2(width, height), Color.BLACK)


	var word_offset = Vector2(width / 2 - 20, height / 2 + 5)
	draw_string(ThemeDB.fallback_font, word_offset, "TEST")

func click() -> void:
	var factory = ShipFactory.new()
	var error = factory.validate(blueprint)
	if error != "":
		print(error)
		return

	var ship = factory.from_grid(blueprint)

	var current: Node = get_tree().current_scene # .duplicate()
	SceneStack.store(current)

	var test_scene_packed: PackedScene = ResourceLoader.load(TEST_SCENE_FILE)
	var test_scene: Node = test_scene_packed.instantiate()

	test_scene.ship = ship

	get_tree().get_root().add_child(test_scene)
	get_tree().set_current_scene(test_scene)
	get_tree().get_root().remove_child(current)
