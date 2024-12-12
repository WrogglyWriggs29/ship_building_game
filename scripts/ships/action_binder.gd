class_name ActionBinder
extends Node

# relates keycodes to an array of factory parts
var bindings: Dictionary = {}

func bind(key: int, part: GridFactory.FactoryPartState) -> void:
	if not bindings.has(key):
		bindings[key] = []
	bindings[key].append(part)

func trigger(key: int) -> void:
	print("pressed " + OS.get_keycode_string(key))
	if bindings.has(key):
		for part in bindings[key]:
			part.action_is_on = true

func untrigger(key: int) -> void:
	print("released " + OS.get_keycode_string(key))
	if bindings.has(key):
		for part in bindings[key]:
			part.action_is_on = false
