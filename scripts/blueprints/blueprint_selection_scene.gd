class_name BlueprintSelectionScene
extends Node2D

const BLUEPRINT_DIR = "user://blueprints/"
const PlayerSelector = preload("res://scripts/blueprints/player_selector.gd")


var player1_selector: PlayerSelector
var player2_selector: PlayerSelector
var start_button: Button

func _ready() -> void:
	var viewport_size = get_viewport().size
	
	# Create player selectors
	player1_selector = PlayerSelector.new(1)
	player2_selector = PlayerSelector.new(2)
	
	# Position and size the selectors
	player1_selector.position = Vector2(0, 0)
	player1_selector.width = viewport_size.x / 2
	player1_selector.height = viewport_size.y - 100
	
	player2_selector.position = Vector2(viewport_size.x / 2, 0)
	player2_selector.width = viewport_size.x / 2
	player2_selector.height = viewport_size.y - 100
	
	# Load blueprints
	player1_selector.load_blueprints(BLUEPRINT_DIR)
	player2_selector.load_blueprints(BLUEPRINT_DIR)
	
	# Create start button
	start_button = Button.new()
	start_button.text = "Start Battle!"
	start_button.position = Vector2(viewport_size.x / 2 - 100, viewport_size.y - 80)
	start_button.size = Vector2(200, 60)
	start_button.pressed.connect(_on_start_pressed)
	
	# Add nodes to scene
	add_child(player1_selector)
	add_child(player2_selector)
	add_child(start_button)

func _input(event: InputEvent) -> void:
	player1_selector.handle_input(event)
	player2_selector.handle_input(event)

func _on_start_pressed() -> void:
	var p1_blueprint = player1_selector.get_selected_blueprint()
	var p2_blueprint = player2_selector.get_selected_blueprint()
	
	if p1_blueprint and p2_blueprint:
		# Start the battle scene with selected blueprints
		var battle_scene = load("res://battle_scene.tscn").instantiate()
		battle_scene.setup_battle(p1_blueprint, p2_blueprint)
		get_tree().get_root().add_child(battle_scene)
		queue_free()
