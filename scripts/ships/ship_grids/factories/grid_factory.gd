class_name GridFactory
extends Node

var modules: Matrix
var move = false


class FactoryPartState extends Node:
	enum Type {EMPTY, DEBUG, THRUSTER}
	var inventory: Inventory
	var type: Type
	var orientation: int
	var action_is_on: bool
	
class OptionalPart extends Node:
	var exists: bool
	var part: FactoryPartState

	func _init(_exists: bool, _part: FactoryPartState = null) -> void:
		exists = _exists
		part = _part

func _init(array = []):
	for y in range(array.size()):
		for x in range(array[y].size()):
			if array[y][x] != null:
				array[y][x] = OptionalPart.new(true, array[y][x])
			else:
				array[y][x] = OptionalPart.new(false)

	modules = Matrix.new(array)

# Moves grid 1 tick forward to move materials, gets current module
func tick_forward() -> void:
	for y in range(modules.rows.size()):
		for x in range(modules.rows[y].members.size()):
			var module = modules.at(x, y)
			move = false
			move_module_part(module, x, y)

# Moves part along conveyor belt 
func move_module_part(module: FactoryPartState, x: int, y: int) -> void:
	var inventory = module.inventory
	# Checks to see if module is empty or not
	if inventory.amount > 0:
		for direction in ["Right", "Left", "Down", "Up"]:
			var next_module = get_next_module(x, y, direction)
			if next_module and move == true and next_module.inventory.amount < next_module.inventory.max_amount:
				next_module.inventory.amount += 1
				inventory.amount -= 1
				break
			# This determines if module is destroyed/doesn't exist/out of bounds, then move back to itself
			else:
				return move_module_part(module, x, y)
	# If no items in module, then move back to itself
	else:
		return move_module_part(module, x, y)


# Determines which direction conveyor should move
func get_next_module(x: int, y: int, direction: String) -> FactoryPartState:
	match direction:
		"Right":
			# if there is a module to the right, then move right
			if x + 1 < modules.rows[y].members.size():
				move = true
				return modules.at(x + 1, y)
		
		"Left":
			# if there is a module to the left, then move left
			if x - 1 >= 0:
				move = true
				return modules.at(x - 1, y)
		
		"Down":
			# if there is a module below, then move down 
			if y + 1 < modules.rows.size():
				move = true
				return modules.at(x, y + 1)
		
		"Up":
			# if there is a module above, then move up
			if y - 1 >= 0:
				move = true
				return modules.at(x, y - 1)
	
	# if module is destroyed/doesn't exist/out of bounds then move back to itself
	return modules.at(x, y)
