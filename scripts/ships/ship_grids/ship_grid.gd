class_name ShipGrid
extends Node2D

var soft_body: GridSoftBody
var factory: GridFactory

func _init(modules: ModuleMatrix, connections: ConnectionMatrix, starting_factory_state: Array) -> void:
	soft_body = GridSoftBody.new(modules, connections)
	factory = GridFactory.new(starting_factory_state)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var starting_index = soft_body.modules.first_module()
	if starting_index == Vector2i(-1, -1):
		return

	tree_draw(starting_index)

func tree_draw(index: Vector2i) -> void:
	pass


func manual_physics_process() -> void:
	for x in factory.modules.width:
		for y in factory.modules.height:
			var optional_part = factory.modules.at(x, y)
			if optional_part.exists:
				var part = optional_part.part
				if part.action_is_on:
					match part.type:
						GridFactory.FactoryPartState.Type.THRUSTER:
							apply_thruster_force(part, Vector2i(x, y))

	soft_body.manual_physics_process()

func apply_thruster_force(part: GridFactory.FactoryPartState, index: Vector2i) -> void:
	var optional_module = soft_body.modules.at_index(index)
	if not optional_module.exists:
		return
	else:
		var module = optional_module.module
		var start_angle = module.phys_rotation.get_value()
		var angle_offset = Dir.to_angle(part.orientation)

		var thruster_angle = Nangle.new(start_angle + angle_offset)
		var thruster_direction = thruster_angle.to_vector()

		apply_force(thruster_direction * 20, index)

func apply_force(_force: Vector2, _index: Vector2i) -> void:
	soft_body.apply_force(_force, _index)
	
func get_average_position() -> Vector2:
	var modules = soft_body.modules

	if modules == null:
		return Vector2.ZERO

	var total_position = Vector2.ZERO
	var count = 0

	# Get x and y coordinates of every vertex. 
	for y in range(modules.height):
		for x in range(modules.width):
			var optional_module = modules.at(x, y)
			if optional_module.exists:
				total_position += optional_module.module.global_position
				count += 1
				#print("vertex is ", optional_module.module.global_position)
			#else:
				#print("Vertex at", x, y, "is null")

	if count == 0:
		return Vector2.ZERO

	return total_position / count
