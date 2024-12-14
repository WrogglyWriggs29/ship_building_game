extends Node

# Store scene paths
const SHIP_DESIGNER_SCENE = "res://ship_blueprint_designer.tscn"
const TUTORIAL_SCENE = "res://scenes/start.tscn"

#const BLUEPRINT_SELECTION_SCENE = "res://scenes/blueprint_selection.tscn"
#const BATTLE_SCENE = "res://scenes/battle_scene.tscn"

func goto_tutorial() -> void:
	var tutorial = load(TUTORIAL_SCENE).instantiate()
	tutorial.start_playback = true
	_switch_scene(tutorial)

# Transition to ship designer scene
func goto_ship_designer() -> void:
	var ship_designer = load(SHIP_DESIGNER_SCENE).instantiate()
	_switch_scene(ship_designer)

# Transition to blueprint selection scene
#func goto_blueprint_selection() -> void:
	#var blueprint_selection = load(BLUEPRINT_SELECTION_SCENE).instantiate()
	#_switch_scene(blueprint_selection)

# Helper function to handle scene switching
func _switch_scene(new_scene: Node) -> void:
	# Store the current scene
	var current_scene = get_tree().current_scene
	SceneStack.store(current_scene)
	
	# Add the new scene to view
	get_tree().get_root().add_child(new_scene)
	get_tree().set_current_scene(new_scene)

	# Remove the current scene from view
	get_tree().get_root().remove_child(current_scene)