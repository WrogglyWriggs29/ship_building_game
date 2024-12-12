class_name ActionBinder
extends Node

# relates keycodes to an array of factory parts
var bindings: Dictionary = {}
var thruster_on : bool = false
var gun_on : bool = false

func bind(key: int, part: GridFactory.FactoryPartState) -> void:
	if not bindings.has(key):
		bindings[key] = []
	bindings[key].append(part)
	print("Type of part: ", part.Type["THRUSTER"])
	print("Thruster type:", GridFactory.FactoryPartState.Type.THRUSTER)

func trigger(key: int) -> void:
	print("pressed " + OS.get_keycode_string(key))
	if bindings.has(key):
		for part in bindings[key]:
			if part.Type["THRUSTER"] == GridFactory.FactoryPartState.Type.THRUSTER:
				thruster_on = true
			if part.Type["GUN"] == GridFactory.FactoryPartState.Type.GUN:
				gun_on = true
			part.action_is_on = true

func untrigger(key: int) -> void:
	print("released " + OS.get_keycode_string(key))
	if bindings.has(key):
		for part in bindings[key]:
			if part.Type["THRUSTER"] == GridFactory.FactoryPartState.Type.THRUSTER:
				thruster_on = false
			if part.Type["GUN"] == GridFactory.FactoryPartState.Type.GUN:
				gun_on = false
			part.action_is_on = false
