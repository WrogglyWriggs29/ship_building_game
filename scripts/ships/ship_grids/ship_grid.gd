class_name ShipGrid
extends Node2D

class VertexIndex:
	var module_index: Vector2i
	var vertex_index: int

	func _init(_module_index: Vector2i, _vertex_index: int) -> void:
		module_index = _module_index
		vertex_index = _vertex_index

var soft_body: GridSoftBody
var factory: GridFactory

func _init(modules: ModuleMatrix, connections: ConnectionMatrix, starting_factory_state: Array) -> void:
	soft_body = GridSoftBody.new(modules, connections)
	factory = GridFactory.new(starting_factory_state)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_vertices()

func draw_vertices() -> void:
	var starting_index = soft_body.modules.first_module()
	if starting_index == Vector2i(-1, -1):
		return

	tree_draw(starting_index, {}, {})

func tree_draw(index: Vector2i, vertices_visited: Dictionary, modules_visited: Dictionary) -> void:
	# prevents visiting the same module twice
	if modules_visited.has(index):
		return
	modules_visited[index] = true

	const SCALE = 5.0

	if not soft_body.modules.in_range(index):
		return

	var optional_module = soft_body.modules.at_index(index)
	if not optional_module.exists:
		return

	#print("index is ", index)
	
	var module = optional_module.module
	var vertices = module.vertices
	for vertex in vertices:
		# this is imperfect, but will mostly work to prevent drawing the same vertex twice
		# if it does get drawn twice, not a crisis
		if not vertices_visited.has(vertex.value):
			vertices_visited[vertex.value] = true
			draw_circle(vertex.value, SCALE, Color.PALE_GREEN)
	
	for corner in CornerDir.MAX:
		var pos1 = vertices[corner].value
		var pos2 = vertices[CornerDir.rotate(corner, true)].value
		draw_line(pos1, pos2, Color.PALE_GREEN)
	
	for dir in Dir.MAX:
		var next_index = soft_body.modules.adjacent_index(index, dir)
		if are_connected(index, next_index):
			tree_draw(next_index, vertices_visited, modules_visited)

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
						GridFactory.FactoryPartState.Type.GUN:
							apply_gun_action(part, Vector2i(x, y))

	soft_body.manual_physics_process()

	find_vertices()

func find_vertices() -> void:
	var starting_index = soft_body.modules.first_module()
	if starting_index == Vector2i(-1, -1):
		return
	
	find_vertices_for_index(starting_index)

func find_vertices_for_index(index: Vector2i, module_visited: Dictionary = {}) -> void:
	# there are basically four cases for any vertex
	# 1. It is determined by a single module
	# this looks like this: 
		#  v   
		#   \ 
		#    m
	# 2. It is determined by two modules
	    #    m
	    #   /|
		#  v |
		#   \|
		#    m
	# 3. It is determined by three modules
		#     m
		#    /|
		#   v |
		#  / \|
		# m---m
	# 4. It is determined by four modules
		# m---m
		# |\ /|
		# | v | 
		# |/ \|
		# m---m
	# where all of these are rotated in 90 degree increments depending on the vertex being set
	# the key observation to the algorithm is that we choose the maximum number of determining modules
	# to achieve this recursively, each module tries to set the highest number it can, then updates the 
	# SharedVector.held_by array to reflect the modules sharing the vertex
	# it doesn't set if it is already set by a higher number of modules, which we can check by looking at the
	# SharedVector.held_by array's size
	if module_visited.has(index):
		return
	module_visited[index] = true

	for corner in CornerDir.MAX:
		find_vertices_for_corner(index, corner)
	
	for dir in Dir.MAX:
		var next_index = soft_body.modules.adjacent_index(index, dir)
		if module_exists(next_index) and are_connected(index, next_index):
			find_vertices_for_index(next_index, module_visited)

func find_vertices_for_corner(index: Vector2i, corner: int) -> void:
	CornerDir.assert_corner_dir(corner)
	var sharers = who_shares(index, corner)
	#print("sharers are ", sharers, " for ", index, " and corner ", corner)
	if sharers.size() == 5:
		set_four_sharers(corner, sharers)
	elif sharers.size() == 4:
		set_three_sharers(corner, sharers)
	elif sharers.size() == 3:
		set_two_sharers(corner, sharers)
	elif sharers.size() == 2:
		set_single_sharer(corner, sharers)

func set_single_sharer(corner: int, sharers: Array) -> void:
	assert(soft_body.modules.at_index(sharers[1]).exists, "Module does not exist, and this shouldn't happen.")

	var module: Module = soft_body.modules.at_index(sharers[1]).module

	# if the vertex is already set, we don't need to do anything
	if module.vertices[corner].held_by.size() > 1:
		return

	var initial_offset = Vector2(GlobalConstants.SCALE / 2, -GlobalConstants.SCALE / 2)

	var dir_angle = Dir.to_angle(CornerDir.dir_clockwise_from(corner))

	var module_angle: Nangle = module.phys_rotation.get_norm()

	var rot_angle = Nangle.new(dir_angle + module_angle.value)

	# need to invert the y axis because godot's y axis is inverted
	var rot_vec = rot_angle.to_vector()
	rot_vec.y = -rot_vec.y

	var final_angle = rot_vec.angle_to(Vector2(1, 0))
	#print("setting single sharer for ", sharers[1], " and corner ", corner, " with angle ", final_angle / PI)
	var vertex_pos = initial_offset.rotated(final_angle) + module.phys_position

	var shared = SharedVector.new(vertex_pos, [module])
	module.vertices[corner] = shared

func set_two_sharers(corner: int, sharers: Array) -> void:
	# this is the case where the vertex is determined by two modules
	# basically, we walk to the midpoint of the two modules, then walk 
	# up or down depending on the path direction of the sharers
	# then we rotate this path by the angle the two form
	var held_by: Array[Module] = []
	for sharer in sharers.slice(1, 3):
		assert(soft_body.modules.at_index(sharer).exists, "Module does not exist, and this shouldn't happen.")
		held_by.push_back(soft_body.modules.at_index(sharer).module)

	var up_offset = -GlobalConstants.SCALE / 2
	var right_offset = Module.distance_between(held_by[0], held_by[1]) / 2

	var path = Vector2(right_offset, up_offset)
	if not sharers[0]:
		path.y = -path.y
	
	var angle = Module.angle_between(held_by[0], held_by[1]).value
	var rotated_path = path.rotated(-angle)
	var shared = SharedVector.new(held_by[0].phys_position + rotated_path, held_by)

	if sharers[0]:
		# walking counter-clockwise around the vertex
		var dir_to_vertex = corner
		for i in 2:
			set_if_better(held_by[i], dir_to_vertex, shared)
			dir_to_vertex = Dir.rotate(dir_to_vertex, false)
	else:
		# walking clockwise around the vertex
		var dir_to_vertex = corner
		for i in 2:
			set_if_better(held_by[i], dir_to_vertex, shared)
			dir_to_vertex = Dir.rotate(dir_to_vertex, true)

func set_three_sharers(corner: int, sharers: Array) -> void:
	# this is the case where the vertex is determined by three modules
	# we imagine a kite where the three modules are three of the vertices
	# the fourth point on the kite is the vertex and extrapolated by assuming radial symmetry
	# 
	# v
	# | \
	# |  \
	# |   \
	# |    2
	# | c  |
	# 0    |
	#  \   |
	#   \  |
	#    \ |
	#     1
	var held_by: Array[Module] = []
	for sharer in sharers.slice(1, 4):
		assert(soft_body.modules.at_index(sharer).exists, "Module does not exist, and this shouldn't happen.")
		held_by.push_back(soft_body.modules.at_index(sharer).module)

	var center = (held_by[0].phys_position + held_by[2].phys_position) / 2
	var shared = SharedVector.new(center, held_by)

	if sharers[0]:
		# walking counter-clockwise around the vertex
		var dir_to_vertex = corner
		for i in 3:
			set_if_better(held_by[i], dir_to_vertex, shared)
			dir_to_vertex = Dir.rotate(dir_to_vertex, false)
	else:
		# walking clockwise around the vertex
		var dir_to_vertex = corner
		for i in 3:
			set_if_better(held_by[i], dir_to_vertex, shared)
			dir_to_vertex = Dir.rotate(dir_to_vertex, true)


func set_four_sharers(corner: int, sharers: Array) -> void:
	# this is the case where the vertex is determined by four modules
	# we can just set the vertex to the average of the four modules
	# we need to set the vertex position for each module
	# we also want to use the same shared vector for all of them
	# we also need to set the held_by array for the shared vector
	var held_by = []
	var average_position = Vector2.ZERO
	for sharer in sharers.slice(1, 5):
		assert(soft_body.modules.at_index(sharer).exists, "Module does not exist, and this shouldn't happen.")

		var module: Module = soft_body.modules.at_index(sharer).module
		held_by.push_back(module)

		average_position += module.phys_position
	
	var shared = SharedVector.new(average_position / 4, held_by as Array[Module])
	if sharers[0]:
		# walking counter-clockwise around the vertex
		var dir_to_vertex = corner
		for i in 4:
			set_if_better(held_by[i], dir_to_vertex, shared)
			dir_to_vertex = Dir.rotate(dir_to_vertex, false)

	else:
		# walking clockwise around the vertex
		var dir_to_vertex = corner
		for i in 4:
			set_if_better(held_by[i], dir_to_vertex, shared)
			dir_to_vertex = Dir.rotate(dir_to_vertex, true)

func who_shares(index: Vector2i, corner_dir: int) -> Array:
	# because modules can be disconnected, we need to do two checks
	# 2---1
	# | v |
	# 3   0
	# and 
	# 2---3
	# | v 
	# 1---0
	# whichever gets more modules is the one we choose
	# we tell the caller which path we chose using the bool at the start of the return array
	var path_0 = [true, index]

	var current_index = index
	var dir_to_next = CornerDir.dir_clockwise_from(corner_dir)
	for i in range(3):
		var next = soft_body.modules.adjacent_index(current_index, dir_to_next)
		if module_exists(next):
			path_0.append(next)
			# rotate counterclockwise to get next direction
			dir_to_next = Dir.rotate(dir_to_next, false)
			current_index = next
		else:
			break
	
	var path_1 = [false, index]

	current_index = index
	dir_to_next = CornerDir.dir_counter_clockwise_from(corner_dir)
	for i in range(3):
		var next = soft_body.modules.adjacent_index(current_index, dir_to_next)
		if module_exists(next):
			path_1.append(next)
			# rotate clockwise to get next direction
			dir_to_next = Dir.rotate(dir_to_next, true)
			current_index = next
		else:
			break
	
	if path_0.size() > path_1.size():
		return path_0
	else:
		return path_1

func set_if_better(module: Module, dir: int, shared: SharedVector) -> void:
	if module.vertices[dir].held_by.size() <= shared.held_by.size():
		module.vertices[dir] = shared


func module_exists(index: Vector2i) -> bool:
	return soft_body.modules.in_range(index) and soft_body.modules.at_index(index).exists

	
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

func apply_gun_action(part: GridFactory.FactoryPartState, index: Vector2i) -> void:
	var optional_module = soft_body.modules.at_index(index)
	if not optional_module.exists:
		return

	var module = optional_module.module
	var start_angle = module.phys_rotation.get_value()
	var angle_offset = Dir.to_angle(part.orientation)
	var gun_angle = Nangle.new(start_angle + angle_offset)
	var gun_direction = gun_angle.to_vector()
	
	spawn_bullet(module.global_position, gun_angle.to_vector(), owner)

func apply_force(_force: Vector2, _index: Vector2i) -> void:
	soft_body.apply_force(_force, _index)

func spawn_bullet(position: Vector2, direction: Vector2, owner_player: Player) -> void:
	var bullet = preload("res://scenes/projectile/projectile.tscn").instantiate()
	bullet.global_position = position
	bullet.rotation = direction.angle()
	bullet.owner_player = owner_player
	# Add projectile to tree
	print("Scene Stuatus", get_tree())
	
	soft_body.add_child(bullet)
	
	print("Trying to spawn bullet here", bullet.position)
	var sprite = bullet.get_node("Sprite2D")
	print("Sprite modulate: ", sprite.modulate)
	print("Sprite visible: ", sprite.visible)
	print("Sprite scale: ", sprite.scale)
	print("Sprite texture: ", sprite.texture)
	
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

func are_connected(mod_ind_a: Vector2i, mod_ind_b: Vector2i) -> bool:
	return soft_body.connections.are_connected(mod_ind_a, mod_ind_b)