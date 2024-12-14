class_name ShipCombatScene
extends Node2D

const FIGHT_SCENE_FILE = "res://scripts/ship_combat_scene/ship_fight_scene.tscn"

@onready var load_dia1 = $LoadDialog1
@onready var load_dia2 = $LoadDialog2

var load1_button = Button.new()
var load2_button = Button.new()

var ship1: Ship = null
var ship2: Ship = null

func _ready() -> void:
	load1_button.text = "Load"
	load1_button.position = Vector2(30, 30)
	load1_button.size = Vector2(100, 100)
	load1_button.connect("pressed", Callable(self, "_on_load_button1_pressed"))
	add_child(load1_button)

	load2_button.text = "Load"
	load2_button.position = Vector2(30, 130)
	load2_button.size = Vector2(100, 100)
	load2_button.connect("pressed", Callable(self, "_on_load_button2_pressed"))
	add_child(load2_button)

	load_dia1.connect("file_selected", Callable(self, "on_load_dia1_file_selected"))
	load_dia2.connect("file_selected", Callable(self, "on_load_dia2_file_selected"))

	load_dia1.current_dir = "res://"
	load_dia2.current_dir = "res://"

	load_dia1.visible = false
	load_dia2.visible = false

func _process(_delta: float) -> void:
	if ship1 == null || ship2 == null:
		return
	
	change_to_fight()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneStack.return_scene()

func change_to_fight() -> void:
	var current: Node = get_tree().current_scene
	SceneStack.store(current)

	var fight_scene_packed: PackedScene = ResourceLoader.load(FIGHT_SCENE_FILE)
	var fight_scene: Node = fight_scene_packed.instantiate()

	ship1.name = "player 1"
	fight_scene.ship1 = ship1

	ship2.name = "player 2"
	fight_scene.ship2 = ship2

	get_tree().get_root().add_child(fight_scene)
	get_tree().set_current_scene(fight_scene)
	get_tree().get_root().remove_child(current)

func _on_load_button1_pressed() -> void:
	load_dia1.visible = true
	load_dia1.popup_centered()

func _on_load_button2_pressed() -> void:
	load_dia2.visible = true
	load_dia2.popup_centered()


func on_load_dia1_file_selected(path: String) -> void:
	var bp: ShipGridBlueprint = load_blueprint(path)
	var factory = ShipFactory.new()
	var err = factory.validate(bp)
	if err != "":
		print("invalid blueprint: ", err)
		return

	var ship = factory.from_grid(bp)
	ship1 = ship

	load1_button.visible = false

func on_load_dia2_file_selected(path: String) -> void:
	var bp: ShipGridBlueprint = load_blueprint(path)
	var factory = ShipFactory.new()
	var err = factory.validate(bp)
	if err != "":
		print("invalid blueprint: ", err)
		return

	var ship = factory.from_grid(bp)
	ship2 = ship

	load2_button.visible = false
	

func load_blueprint(file_path: String) -> ShipGridBlueprint:
	var reader = BlueprintReader.new()

	print("Loading blueprint from:", file_path)
	var loaded_blueprint = reader.load_ship_grid_from_json(file_path)
	if loaded_blueprint == null:
		print("Failed to load blueprint.")
		return
	print("Blueprint loaded successfully.")

	return loaded_blueprint

func _physics_process(_delta: float) -> void:
	pass
	#ship.manual_physics_process() # grid.soft_body.manual_physics_process()
