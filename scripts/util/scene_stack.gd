extends Node

# Scene stack stores scenes in a stack so that they can be returned to in the order they were added.

var scenes: Array[Node] = []

func store(scene: Node) -> void:
	scenes.push_back(scene)

func return_scene() -> void:
	if scenes.size() > 0:
		var current = get_tree().current_scene

		var new = scenes.pop_back()
		get_tree().get_root().add_child(new)
		get_tree().set_current_scene(new)
		get_tree().get_root().remove_child(current)
	else:
		printerr("Could not return to scene: No scenes stored.")
