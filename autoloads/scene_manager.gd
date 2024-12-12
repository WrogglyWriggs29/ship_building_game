extends Node

# Store scene paths
const SHIP_DESIGNER_SCENE = "res://scenes/ship_blueprint_designer.tscn"
const BLUEPRINT_SELECTION_SCENE = "res://scenes/blueprint_selection.tscn"
const BATTLE_SCENE = "res://scenes/battle_scene.tscn"

# Transition to ship designer scene
func goto_ship_designer() -> void:
	var ship_designer = load(SHIP_DESIGNER_SCENE).instantiate()
	_switch_scene(ship_designer)

# Transition to blueprint selection scene
func goto_blueprint_selection() -> void:
	var blueprint_selection = load(BLUEPRINT_SELECTION_SCENE).instantiate()
	_switch_scene(blueprint_selection)

# Helper function to handle scene switching
func _switch_scene(new_scene: Node) -> void:
	# Get the current scene
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	
	# Remove the current scene
	root.remove_child(current_scene)
	current_scene.queue_free()
	
	# Add the new scene
	root.add_child(new_scene)
	get_tree().set_current_scene(new_scene)
