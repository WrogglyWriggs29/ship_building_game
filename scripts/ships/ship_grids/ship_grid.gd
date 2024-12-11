class_name ShipGrid
extends Node2D

var soft_body: GridSoftBody
var factory: GridFactory


# this does nothing right now
class ModuleVertexArray:
	extends Object

	var vertices: Matrix
	var modules: ModuleMatrix
	func _init(_modules: ModuleMatrix) -> void:
		modules = _modules

		var width = modules.width + 1
		var height = modules.height + 1
		var vertices_array = Matrix.make_array(width, height, Vector2.ZERO)

		vertices = Matrix.new(vertices_array)
	
	func update() -> void:
		pass
		# use the module matrix to update the vertices
		# each vertex is the average of the four nodes it's between
		# when nodes are null, ghost nodes are predicted based on other nodes, then the average is taken
		#var ghosts = find_ghosts()
		#assert(ghosts.width == vertices.width + 2 && ghosts.height == vertices.height + 2, "Ghost matrix must be 2 larger in each dimension than the vertex matrix.")
		#for x in vertices.width:
		#    for y in vertices.height:
		#        var pos_tl = ghosts.at(x, y)
		#        var pos_tr = ghosts.at(x + 1, y)
		#        var pos_bl = ghosts.at(x, y + 1)
		#        var pos_br = ghosts.at(x + 1, y + 1)
		#        vertices.set(x, y, (pos_tl + pos_tr + pos_bl + pos_br) / 4.0)
	
	#func find_ghosts() -> GhostMatrix:


var shape_vertices: ModuleVertexArray

func _init(modules: ModuleMatrix, connections: ConnectionMatrix, starting_factory_state: Array) -> void:
	soft_body = GridSoftBody.new(modules, connections)
	factory = GridFactory.new(starting_factory_state)
	shape_vertices = ModuleVertexArray.new(modules) # Initialize shape_vertices

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
