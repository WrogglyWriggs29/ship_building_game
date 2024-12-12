class_name ShipGrid
extends Node2D

class VertexIndex:
	var module_index: Vector2i
	var vertex_index: int

	func _init(_module_index: Vector2i, _vertex_index: int) -> void:
		module_index = _module_index
		vertex_index = _vertex_index

class CollisionPolygon:
	var boundary: Array[SharedVector] = []

	# uses boundary to compute below values
	var centroid: Vector2
	var max_radius: float

	# recomputes polygon on-demand, 
	# and avoids recomputing if boundary hasn't been updated since last computation
	var _polygon_up_to_date: bool = false
	var _collision_polygon: PackedVector2Array

	func _init(_boundary: Array[SharedVector]) -> void:
		boundary = _boundary
	
	func update(_boundary) -> void:
		boundary = _boundary
		_polygon_up_to_date = false
	
	func get_polygon() -> PackedVector2Array:
		_collision_polygon = pack_shared_vectors(boundary)
		if _collision_polygon.size() > 0:
			_collision_polygon.push_back(_collision_polygon[0])
		_polygon_up_to_date = true
		return _collision_polygon
	
	func compile() -> void:
		#collision_polygon = pack_shared_vectors(boundary)
		centroid = compute_centroid()
		max_radius = compute_max_radius(centroid)

	func pack_shared_vectors(shared_vectors: Array[SharedVector]) -> PackedVector2Array:
		var values: Array[Vector2] = []
		for shared in shared_vectors:
			values.push_back(shared.value)
		return values
	
	func compute_centroid() -> Vector2:
		var sum = Vector2.ZERO
		for shared in boundary:
			sum += shared.value
		return sum / boundary.size()
	
	func compute_max_radius(_centroid: Vector2) -> float:
		var _max_radius = 0.0
		for shared in boundary:
			var dist = shared.value.distance_to(_centroid)
			if dist > _max_radius:
				_max_radius = dist
		
		return _max_radius
	
	static func may_collide(a: CollisionPolygon, b: CollisionPolygon) -> bool:
		var dist = a.centroid.distance_to(b.centroid)
		var max_dist = a.max_radius + b.max_radius
		return dist < max_dist

var soft_body: GridSoftBody
var factory: GridFactory

var width: int
var height: int

var boundary: Array[SharedVector] = []
var collision_polygon: PackedVector2Array

var collider: CollisionPolygon

var debug_draw_colliding: Array[Vector2] = []

func _init(modules: ModuleMatrix, connections: ConnectionMatrix, starting_factory_state: Array) -> void:
	width = modules.width
	height = modules.height
	soft_body = GridSoftBody.new(modules, connections)
	factory = GridFactory.new(starting_factory_state)
	collider = CollisionPolygon.new([])


func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_colored_polygon(collider.get_polygon(), Color(0.5, 0.5, 0.5, 0.5))

	draw_vertices()
	var to_draw: Array[SharedVector] = boundary
	if to_draw.size() > 1:
		for i in range(1, to_draw.size()):
			draw_line(to_draw[i - 1].value, to_draw[i].value, Color.INDIAN_RED)
		draw_line(to_draw[to_draw.size() - 1].value, to_draw[0].value, Color.INDIAN_RED)

	var boundary = collider.get_polygon()
	draw_polyline(boundary, Color.INDIAN_RED, 3)

	for point in debug_draw_colliding:
		draw_circle(point, 5.0, Color.RED)

func manual_physics_process() -> Array[DisconnectionEvent]:
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

	var dc: Array[DisconnectionEvent] = soft_body.manual_physics_process()

	find_vertices()
	collider.update(find_bounding())
	collider.compile()
	#collision_polygon = pack_shared_vectors(boundary)

	return dc

func collide(polygon: PackedVector2Array) -> void:
	const BACKOUT_LENGTH = 200.0
	debug_draw_colliding.clear()

	#print("Center at ", avg, " centroid at ", collider.centroid)
	var union = Geometry2D.intersect_polygons(polygon, collider.get_polygon())
	#print(polygon, " ", collider.centroid, " ", union)

	for poly in union:
		for shared in collider.boundary:
			if Geometry2D.is_point_in_polygon(shared.value, poly):
				debug_draw_colliding.push_back(shared.value)

				var nearest = closest_point_on_polygon(shared.value, polygon)
				var backout_path = nearest - shared.value
				debug_draw_colliding.push_back(shared.value + backout_path)

				var distance_out = backout_path.length()

				var speed = distance_out / GlobalConstants.TIME_STEP_CONSTANT

				var accel = backout_path.normalized() * speed

				for module in shared.held_by:
					module.apply_accel(accel)

					#debug_draw_colliding.push_back(backout_clipped[0][1])
		
func closest_point_on_polygon(pos: Vector2, polygon: PackedVector2Array) -> Vector2:
	var closest = polygon[0]
	var closest_dist = closest.distance_to(pos)
	for i in range(1, polygon.size()):
		var close = Geometry2D.get_closest_point_to_segment(pos, polygon[i - 1], polygon[i])
		if close.distance_to(pos) < closest_dist:
			closest = close
			closest_dist = close.distance_to(pos)
	return closest

class ModuleCorner:
	var m_index: Vector2i
	var corner_dir: int

	func _init(_m_index: Vector2i, _corner_dir: int) -> void:
		m_index = _m_index
		corner_dir = _corner_dir

func find_bounding() -> Array[SharedVector]:
	var starting_index = soft_body.modules.first_module()
	if starting_index == Vector2i(-1, -1):
		return []
	
	var to_draw: Array[SharedVector] = []

	var termination_position = ModuleCorner.new(starting_index, CornerDir.UP_LEFT)
	to_draw.push_back(soft_body.modules.at_index(starting_index).module.vertices[CornerDir.UP_LEFT])

	recurse_find_bounding(starting_index, Dir.RIGHT, 0, termination_position, to_draw)
	return to_draw

func recurse_find_bounding(cur_mod: Vector2i, prefer_dir: int, level: int, stop_cond: ModuleCorner, to_draw: Array[SharedVector]) -> void:
	#if level > 2:
	#	return
	# think of prefer_dir as up for convenience
	# in reality, it's just the direction ccw of where we came from
	assert(soft_body.modules.at_index(cur_mod).exists, "Module does not exist, and this shouldn't happen.")

	var module = soft_body.modules.at_index(cur_mod).module

	# we start from the top left, but this will get skipped
	#to_draw.push_back(module.vertices[CornerDir.UP_LEFT].value)
	# if, instead, we start with a gap in the up direction, we look for the first non-gap in the clockwise direction
	for rot_offset in range(0, 4):
		var next_dir = Dir.rotate_times(prefer_dir, true, rot_offset)
		if cur_mod == stop_cond.m_index and CornerDir.corner_dir_counter_clockwise_from(next_dir) == stop_cond.corner_dir:
			return
		var next_mod = soft_body.modules.adjacent_index(cur_mod, next_dir)
		if not are_connected(cur_mod, next_mod):
			var rotated_through = CornerDir.corner_dir_counter_clockwise_from(next_dir)
			var vertex = module.vertices[rotated_through]
			to_draw.append(vertex)
			#draw_string(ThemeDB.fallback_font, vertex.value, str(level) + " " + str(rot_offset) + " " + Dir.string(next_dir))
			continue
		else:
			recurse_find_bounding(next_mod, Dir.rotate(next_dir, false), level + 1, stop_cond, to_draw)
			break

func disconnect_cons(a: Vector2i, b: Vector2i) -> void:
	soft_body.connections.at_index(a).exists = false
	soft_body.connections.at_index(b).exists = false

func assert_valid_connection_pair(cons: Array[Vector2i], event: DisconnectionEvent) -> void:
	assert(cons.size() == 2, name_str() + "Couldn't find connections between " + str(event.a) + " and " + str(event.b))
	assert(connection_exists(cons[0]), name_str() + "Couldn't find outgoing connection at index " + str(cons[0]) + " from index " + str(event.a))
	assert(connection_exists(cons[1]), name_str() + "Couldn't find outgoing connection at index " + str(cons[1]) + " from index " + str(event.b))

func name_str() -> String:
	return "Grid '" + name + "': "

# given a starting connection index and an ending connection index, determine whether a path exists between them
# along other connections
# a and b should no longer exist/be connected
# a breadth first search is likely to be much faster than a depth first search
func find_from(a: Vector2i, b: Vector2i) -> bool:
	var from = mod_of_con(a)
	var target = mod_of_con(b)

	var queue = []

	# note that visited will hold module indices, not connection indices
	var visited = {}

	queue.append(from)
	visited[from] = true

	while queue.size() > 0:
		var current = queue.pop_front()
		if current == target:
			return true

		for dir in Dir.MAX:
			var next_con = soft_body.connections.index_from_module(current, dir)
			var next_mod = soft_body.modules.adjacent_index(current, dir)
			if connection_exists(next_con) and not visited.has(next_mod):
				queue.append(next_mod)
				visited[next_mod] = true

	return false

func mod_of_con(con_i: Vector2i) -> Vector2i:
	return Vector2i(floor(con_i.x / 2.0), floor(con_i.y / 2.0))

func con_from_con(con_i: Vector2i, dir: int) -> Vector2i:
	Dir.assert_dir(dir)
	var mod_i = mod_of_con(con_i)
	return soft_body.connections.index_from_module(mod_i, dir)

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

func clear_vertices() -> void:
	for x in range(soft_body.modules.width):
		for y in range(soft_body.modules.height):
			var optional_module = soft_body.modules.at(x, y)
			if optional_module.exists:
				var module = optional_module.module
				for corner in CornerDir.MAX:
					module.vertices[corner] = SharedVector.new(Vector2.ZERO, [])

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
	module_visited[index] = true

	for corner in CornerDir.MAX:
		find_vertices_for_corner(index, corner)
	
	for dir in Dir.MAX:
		var next_index = soft_body.modules.adjacent_index(index, dir)
		if module_visited.get(next_index) != null:
			continue
		# note are_connected does range/existence checking
		if are_connected(index, next_index):
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
			set_if_better(held_by[i], dir_to_vertex, shared, 2)
			dir_to_vertex = Dir.rotate(dir_to_vertex, false)
	else:
		# walking clockwise around the vertex
		var dir_to_vertex = corner
		for i in 2:
			set_if_better(held_by[i], dir_to_vertex, shared, 2)
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
			set_if_better(held_by[i], dir_to_vertex, shared, 3)
			#dir_to_vertex = Dir.rotate(dir_to_vertex, false)
			dir_to_vertex = Dir._counter_clockwise_dirs[dir_to_vertex]
	else:
		# walking clockwise around the vertex
		var dir_to_vertex = corner
		for i in 3:
			set_if_better(held_by[i], dir_to_vertex, shared, 3)
			#dir_to_vertex = Dir.rotate(dir_to_vertex, true)
			dir_to_vertex = Dir._clockwise_dirs[dir_to_vertex]


func set_four_sharers(corner: int, sharers: Array) -> void:
	# this is the case where the vertex is determined by four modules
	# we can just set the vertex to the average of the four modules
	# we need to set the vertex position for each module
	# we also want to use the same shared vector for all of them
	# we also need to set the held_by array for the shared vector
	# this is kinda unreadable because it's a very important function to efficiency
	var average_position = Vector2.ZERO
	var dir_to_vertex = corner
	var ccw = sharers[0]
	var shared = SharedVector.new(Vector2.ZERO, [])
	for i in range(1, 5):
		#assert(soft_body.modules.at_index(sharer).exists, "Module does not exist, and this shouldn't happen.")
		var module: Module = soft_body.modules.at_index(sharers[i]).module

		module.vertices[dir_to_vertex] = shared
		shared.held_by.push_back(module)
		
		if ccw:
			dir_to_vertex = Dir._counter_clockwise_dirs[dir_to_vertex]
		else:
			dir_to_vertex = Dir._clockwise_dirs[dir_to_vertex]

		average_position += module.phys_position
	
	shared.value = average_position / 4

func set_if_better(module: Module, dir: int, shared: SharedVector, size: int) -> void:
	if module.vertices[dir].held_by.size() <= size:
		module.vertices[dir] = shared

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
	
	#print("Trying to spawn bullet here", bullet.position)
	var sprite = bullet.get_node("Sprite2D")
	#print("Sprite modulate: ", sprite.modulate)
	#print("Sprite visible: ", sprite.visible)
	#print("Sprite scale: ", sprite.scale)
	#print("Sprite texture: ", sprite.texture)
	
func get_position_sum() -> Array:
	var modules = soft_body.modules

	if modules == null:
		return [Vector2.ZERO, 0]

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

	return [total_position, count]

func are_connected(mod_ind_a: Vector2i, mod_ind_b: Vector2i) -> bool:
	return module_exists(mod_ind_b) and soft_body.connections.are_connected(mod_ind_a, mod_ind_b)

func connection_exists(ind: Vector2i) -> bool:
	return soft_body.connections.in_range(ind) and soft_body.connections.at_index(ind).exists
	
func is_thruster(index: Vector2i) -> bool:
	# Check if the module at the given index is a thruster
	if factory.modules.in_range(index):
		var optional_part = factory.modules.at(index.x, index.y)
		if optional_part.exists:
			return optional_part.part.type == GridFactory.FactoryPartState.Type.THRUSTER
	return false

func is_gun(index: Vector2i) -> bool:
	# Check if the module at the given index is a gun
	if factory.modules.in_range(index):
		var optional_part = factory.modules.at(index.x, index.y)
		if optional_part.exists:
			return optional_part.part.type == GridFactory.FactoryPartState.Type.GUN
	return false
