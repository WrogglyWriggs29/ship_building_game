class_name GridSoftBody
extends Node2D

# GridSoftBody holds the information needed to run the ShipGrid's physics simulation
# Step the physics simulation forward by one tick by calling manual_physics_process()

var modules: ModuleMatrix
var connections: ConnectionMatrix

var angular_displacements: DisplacementMatrix

var debug_draw: bool = false
var debug_applied_forces: Array = []

class LineCoords:
	var start: Vector2
	var end: Vector2
	func _init(_start: Vector2, _end: Vector2) -> void:
		self.start = _start
		self.end = _end

class VisitedMatrix:
	var matrix: Matrix
	func _init(width: int, height: int) -> void:
		var bool_array = Matrix.make_array(width, height, false)
		matrix = Matrix.new(bool_array)
	
	func at(index: Vector2i) -> bool:
		return matrix.at_index(index)
	
	func mark(index: Vector2i, value: bool) -> void:
		matrix.set_at_index(index, value)
	
	func mark_all(value: bool) -> void:
		for y in matrix.rows.size():
			for x in matrix.rows[y].members.size():
				matrix.set_at(x, y, value)

func _init(_modules, _connections) -> void:
	modules = _modules
	connections = _connections
	angular_displacements = DisplacementMatrix.new(_connections)

func _ready() -> void:
	debug_draw = true

func _process(_delta: float) -> void:
	if debug_draw:
		queue_redraw()

func _draw() -> void:
	var connection_lines = find_connection_lines()

	# connections
	for line in connection_lines:
		self.draw_line(line.start, line.end, Color.WHITE, 2.0)
	
	# module dots
	modules.draw_module_dots(self)
	modules.draw_module_rotations(self)

	for y_index in modules.height:
		for x_index in modules.width:
			var index = Vector2i(x_index, y_index)
			if modules.at_index(index).exists:
				draw_module_outgoing_angles(index)

func apply_force(force: Vector2, index: Vector2i) -> void:
	var optional_module = modules.at_index(index)
	if optional_module.exists:
		optional_module.module.apply_accel(force / optional_module.module.mass)

func manual_physics_process() -> Array[DisconnectionEvent]:
	var dc: Array[DisconnectionEvent] = []

	update_displacement_angles()
	update_node_rotations()

	dc.append_array(apply_torque_forces())
	dc.append_array(apply_spring_forces())

	dampen_locally_allow_curl(get_center_of_mass())

	modules.manual_physics_process()

	return dc

func get_center_of_mass() -> Vector2:
	var sum = Vector2.ZERO
	var mass_sum = 0.0
	for y_index in modules.height:
		for x_index in modules.width:
			var current = Vector2i(x_index, y_index)
			var optional_module = modules.at_index(current)
			if optional_module.exists:
				sum += optional_module.module.position * optional_module.module.mass
				mass_sum += optional_module.module.mass
	assert(mass_sum != 0, "grid mass is zero")
	return sum / mass_sum

func dampen_locally_allow_curl(com: Vector2) -> void:
	var new_velocities = []
	for y_index in modules.height:
		var row: Array[Vector2] = []
		for x_index in modules.width:
			var current = Vector2i(x_index, y_index)
			var optional_module = modules.at_index(current)
			if optional_module.exists:
				var adjacent_modules: Array[OptionalModule] = get_adjacent_modules(current)
				var avg = get_average_velocity(optional_module.module, adjacent_modules)
				var tangent_direction = (optional_module.module.position - com).normalized().rotated(PI / 2)
				var new_velocity = dampen_velocity(optional_module.module.velocity, avg, tangent_direction)
				row.append(new_velocity)
			else:
				row.append(Vector2.ZERO)
		new_velocities.append(row)
	
	var new_velocity_matrix = Matrix.new(new_velocities)

	for y_index in modules.height:
		for x_index in modules.width:
			var current = Vector2i(x_index, y_index)
			var optional_module = modules.at_index(current)
			if optional_module.exists:
				optional_module.module.velocity = new_velocity_matrix.at(x_index, y_index)

func get_average_velocity(module: Module, adjacent_modules: Array[OptionalModule]) -> Vector2:
	var sum = module.velocity
	var count = 1
	for dir in Dir.MAX:
		if adjacent_modules[dir].exists:
			sum += adjacent_modules[dir].module.velocity
			count += 1
	return sum / count

func dampen_velocity(velocity: Vector2, avg: Vector2, tangent_direction: Vector2) -> Vector2:
	var non_average = velocity - avg
	#var tangent_component = non_average.project(tangent_direction)
	#if tangent_direction == Vector2.ZERO:
	#	tangent_component = Vector2.ZERO
	var to_dampen = non_average # - tangent_component

	to_dampen *= GlobalConstants.DAMPING_FACTOR

	#tangent_component *= GlobalConstants.CURL_DAMPING_CONSTANT
	avg *= GlobalConstants.FRICTION_FACTOR
	return to_dampen + avg # + tangent_component

	#const DAMPING_CONSTANT = 0.1
	#return velocity * (1 - DAMPING_CONSTANT) + avg * DAMPING_CONSTANT

func apply_torque_forces() -> Array[DisconnectionEvent]:
	var dc: Array[DisconnectionEvent] = []

	for y_index in modules.height:
		for x_index in modules.width:
			var current = Vector2i(x_index, y_index)
			var optional_module = modules.at_index(current)
			if optional_module.exists:
				var adjacent_modules: Array[OptionalModule] = get_adjacent_modules(current)
				dc.append_array(apply_torque_forces_to_module(current, optional_module.module, adjacent_modules))

	return dc

func apply_torque_forces_to_module(index: Vector2i, module: Module, adjacent_modules: Array[OptionalModule]) -> Array[DisconnectionEvent]:
	var dc: Array[DisconnectionEvent] = []
	var force_sum: Vector2 = Vector2.ZERO
	var force_count = 0
	for dir in Dir.MAX:
		if adjacent_modules[dir].exists:
			var neighbor = adjacent_modules[dir].module
			var optional_connection = connections.connection_from_module(index, dir)
			if optional_connection.exists:
				var displacement = angular_displacements.from_module_index(index, dir)

				var torque = optional_connection.connection.k_angular * displacement.get_value()
				if abs(torque) > optional_connection.connection.breaking_torque:
					torque = sign(torque) * optional_connection.connection.breaking_torque
					dc.append(DisconnectionEvent.new(index, modules.adjacent_index(index, dir)))

				var dist = Module.distance_between(module, neighbor)
				var force = torque * stability_factor(dist) / dist
				#var accel = force / neighbor.mass
				var tangent_direction = Module.tangent_direction(module, neighbor)
				var force_vector = tangent_direction * force
				force_sum += force_vector
				force_count += 1
				var accel: Vector2 = force_vector / neighbor.mass
				var velocity: Vector2 = accel # times time constant

				var correction = radial_correction(velocity, module.position, neighbor.position)

				neighbor.apply_accel(velocity) # * GlobalConstants.ANGULAR_DAMPING_FACTOR)
				neighbor.apply_accel(correction) # * GlobalConstants.ANGULAR_DAMPING_FACTOR)
				#neighbor.velocity += accel_vector * 0.01
	
	if force_count > 0:
		var avg_force = force_sum / force_count
		module.apply_accel(-avg_force * 2 / module.mass)
	
	return dc

func apply_spring_forces() -> Array[DisconnectionEvent]:
	var dc: Array[DisconnectionEvent] = []
	var visited: Dictionary = {}
	# visited is a dictionary of Vector2i -> Array[Vector2i]
	# when b is visited from a, visited[b].push_back(a)
	for x in modules.width:
		for y in modules.height:
			var current = Vector2i(x, y)

			var cur_mod = modules.at_index(current)
			if not cur_mod.exists:
				continue
			
			for dir in Dir.MAX:
				var neighbor = modules.adjacent_index(current, dir)
				if visited.has(current) and visited[current].has(neighbor):
					continue

				if modules.in_range(neighbor):
					if not visited.has(neighbor):
						visited[neighbor] = [current]
					else:
						visited[neighbor].push_back(current)

					var neigh_mod = modules.at_index(neighbor)
					if not neigh_mod.exists:
						continue

					var con_cur = connections.connection_from_module(current, dir)
					var con_neigh = connections.connection_from_module(neighbor, Dir.reverse(dir))
					if con_cur.exists and con_neigh.exists:
						var disconnected: bool = simulate_spring(cur_mod.module, neigh_mod.module, con_cur.connection, con_neigh.connection)
						if disconnected:
							dc.push_back(DisconnectionEvent.new(current, neighbor))

	return dc

func hash_vector2i(v: Vector2i) -> int:
	return v.x * 1000 + v.y

func simulate_spring(m_a: Module, m_b: Module, c_a: Connection, c_b: Connection) -> bool:
	var ret = false
	var delta_vector: Vector2 = m_b.phys_position - m_a.phys_position
	var dir: Vector2 = delta_vector.normalized()
	var dist: float = delta_vector.length()
	
	var keq = keq2(c_a.k_linear, c_b.k_linear)
	var neutral_eq = GlobalConstants.SCALE
	var displ = neutral_eq - dist
	
	var force = keq * displ
	if abs(force) > min(c_a.breaking_force, c_b.breaking_force):
		ret = true
		force = sign(force) * min(c_a.breaking_force, c_b.breaking_force)

	var accel_a = -dir * force / m_a.mass
	var accel_b = dir * force / m_b.mass

	m_a.apply_accel(accel_a) # * GlobalConstants.LINEAR_DAMPING_FACTOR)
	m_b.apply_accel(accel_b) # * GlobalConstants.LINEAR_DAMPING_FACTOR)
	return ret

# Equivalent k for two springs in series
func keq2(k_a: float, k_b: float) -> float:
	return (k_a * k_b) / (k_a + k_b)

# when distance goes to near-zero, force blows up to infinity
# this function scales the force to prevent that
func stability_factor(distance: float) -> float:
	# faster dropoff rate means less force at the same distances
	# raise this number to decrease the stabilization effect
	const DROPOFF_RATE = 0.6
	var b = -2

	return -b / (1 + exp(-DROPOFF_RATE * (distance / GlobalConstants.SCALE))) + b + 1

func apply_repulsion_forces() -> void:
	for y_index in modules.height:
		for x_index in modules.width:
			var current = Vector2i(x_index, y_index)
			var optional_module = modules.at_index(current)
			if optional_module.exists:
				var adjacent_modules: Array[OptionalModule] = get_adjacent_modules(current)
				apply_repulsion_forces_to_module(optional_module.module, adjacent_modules)

func apply_repulsion_forces_to_module(module: Module, adjacent_modules: Array[OptionalModule]) -> void:
	for dir in Dir.MAX:
		if adjacent_modules[dir].exists:
			var neighbor = adjacent_modules[dir].module
			var amt = repulsion_factor(Module.distance_between(module, neighbor))
			#if amt <= 0.2:
			#	continue

			var direction = (module.position - neighbor.position).normalized()
			var incoming_vel = neighbor.velocity.project(direction)

			# only apply repulsion if neighbor is moving towards the module
			#if incoming_vel.x * direction.x + incoming_vel.y * direction.y < 0:
			#	continue
			
			neighbor.apply_accel(amt * (-direction)) # * incoming_vel.length()))

func repulsion_factor(distance: float) -> float:
	const REPULSION_FACTOR = 0.1
	const CUTOFF_FACTOR = 0.4
	return maxf(0.0, REPULSION_FACTOR / (distance / GlobalConstants.SCALE) - CUTOFF_FACTOR)


# apply a small acceleration inwards proportional to velocity to help correct tangent velocity bleeding
func radial_correction(velocity: Vector2, center: Vector2, start: Vector2) -> Vector2:
	const CORRECTION_FACTOR = 0.12
	var negated_velocity = -CORRECTION_FACTOR * velocity
	var inwards_velocity = (center - start).normalized() * velocity.length() * CORRECTION_FACTOR
	return negated_velocity + inwards_velocity

func find_connection_lines() -> Array[LineCoords]:
	var lines: Array[LineCoords] = []

	var is_visited = VisitedMatrix.new(connections.width, connections.height)

	for y_index in connections.height:
		for x_index in connections.width:
			var current = Vector2i(x_index, y_index)
			
			if is_visited.at(current):
				continue
			
			var neighbor = connections.linked_index(current)
			if connections.at_index(current).exists && connections.in_range(neighbor):
				var a = modules.at_connection_index(current)
				var b = modules.at_connection_index(neighbor)

				if a.exists && b.exists:
					var module_a_pos = a.module.global_position
					var module_b_pos = b.module.global_position
					lines.append(LineCoords.new(module_a_pos, module_b_pos))

				is_visited.mark(neighbor, true)
			
			is_visited.mark(current, true)
	
	return lines

func update_displacement_angles() -> void:
	var is_visited = VisitedMatrix.new(modules.width, modules.height)
	for y_index in modules.height:
		for x_index in modules.width:
			var current = Vector2i(x_index, y_index)
			
			if is_visited.at(current):
				continue
			
			if not modules.at_index(current).exists:
				is_visited.mark(current, true)
				continue

			else:
				for dir in Dir.MAX:
					var neighbor_index = modules.adjacent_index(current, dir)
					if !modules.in_range(neighbor_index) || is_visited.at(neighbor_index):
						continue
					if modules.at_index(neighbor_index).exists:
						if connections.connection_from_module(current, dir).exists:
							update_displacements(current, neighbor_index, dir)
			
			is_visited.mark(current, true)

func update_node_rotations() -> void:
	for y_index in modules.height:
		for x_index in modules.width:
			var current = Vector2i(x_index, y_index)
			var optional_module = modules.at_index(current)
			if optional_module.exists:
				var adjacent_modules: Array[OptionalModule] = get_adjacent_modules(Vector2i(x_index, y_index))
				update_node_rotation(current, optional_module.module, adjacent_modules)

func update_node_rotation(index: Vector2i, module: Module, adjacent_modules: Array[OptionalModule]) -> void:
	# currently, the formula looks something like 
	# a = sum(displ * kr)
	#     ---------------
	#     sum(kr)
	var connection_angle_kr_tuples: Array[Array] = []
	for dir in Dir.MAX:
		if adjacent_modules[dir].exists:
			var optional_connection = connections.connection_from_module(index, dir)
			if optional_connection.exists:
				var displacement = angular_displacements.from_module_index(index, dir)
				var kr = optional_connection.connection.k_angular
				connection_angle_kr_tuples.append([optional_connection.connection, displacement.get_value(), kr])
	
	var sum_prods = 0.0
	var sum_kr = 0.0
	for tuple in connection_angle_kr_tuples:
		sum_prods += tuple[1] * tuple[2]
		sum_kr += tuple[2]
	
	if sum_kr != 0:
		module.phys_rotation.add(sum_prods / (2 * sum_kr))

	#var to_print: String = ""
	#var i = 0
	#for tuple in connection_angle_kr_tuples:
	#	to_print += "displ " + str(i) + ": " + str(Fangle.new(tuple[1]).get_mult()) + " "
	#	i += 1
	#to_print += "rot: " + str(module.physics_rotation.get_mult())
	#print(to_print)

func angle_to_cardinal(angle: Fangle, dir: int) -> Fangle:
	var desired_angle := Nangle.from_dir(dir)
	var desired_positive = clampf(desired_angle.value, 0, 2 * PI)

	return Fangle.new(angle.get_value() - desired_positive)

func get_adjacent_modules(index: Vector2i) -> Array[OptionalModule]:
	var neighbors: Array[OptionalModule] = []
	for dir in Dir.MAX:
		var neighbor_index = modules.adjacent_index(index, dir)
		if modules.in_range(neighbor_index):
			neighbors.append(modules.at_index(neighbor_index))
		else:
			neighbors.append(OptionalModule.new(false))
	
	return neighbors

# update the angles of the connections between two modules to reflect the module positions
# the connection angles track rotation count, so increment them by the difference in module angles
# this assumes that the modules haven't rotated since the last time this was called
func update_displacements(a: Vector2i, b: Vector2i, a_b_dir: int) -> void:
	var b_a_dir = Dir.reverse(a_b_dir)

	var a_con_index = connections.index_from_module(a, a_b_dir)
	var b_con_index = connections.index_from_module(b, b_a_dir)

	var a_b_angle: Nangle = Module.angle_between(modules.at_index(a).module, modules.at_index(b).module)
	var b_a_angle: Nangle = Module.angle_between(modules.at_index(b).module, modules.at_index(a).module)

	var a_b_desired: Nangle = desired_norm(a_b_dir, modules.at_index(a).module.phys_rotation)
	var b_a_desired: Nangle = desired_norm(b_a_dir, modules.at_index(b).module.phys_rotation)

	var a_b_displacement_norm := Nangle.shortest_difference(a_b_angle, a_b_desired)
	var b_a_displacement_norm := Nangle.shortest_difference(b_a_angle, b_a_desired)

	var current_a_b_displacement: Fangle = angular_displacements.at_index(a_con_index)
	var current_b_a_displacement: Fangle = angular_displacements.at_index(b_con_index)

	var a_b_update_norm := Nangle.shortest_difference(a_b_displacement_norm, current_a_b_displacement.get_norm())
	var b_a_update_norm := Nangle.shortest_difference(b_a_displacement_norm, current_b_a_displacement.get_norm())

	current_a_b_displacement.add(a_b_update_norm.value)
	current_b_a_displacement.add(b_a_update_norm.value)

func draw_module_outgoing_angles(index: Vector2i) -> void:
	const SCALE = 15.0
	for dir in Dir.MAX:
		var connection = connections.connection_from_module(index, dir)
		if connection.exists:
			var displacement_angle = angular_displacements.from_module_index(index, dir)
			var default_angle = desired_norm(dir, modules.at_index(index).module.phys_rotation)

			var angle = Fangle.new(displacement_angle.get_value() + default_angle.value)

			var module = modules.at_index(index).module
			var start = module.global_position

			var end = start + angle.to_vector() * SCALE
			draw_dashed_line(start, end, Color.RED, 2.0)

# rotate default angle by node's rotation to get the desired angle
func desired_norm(dir: int, node_rotation: Fangle) -> Nangle:
	var default := Nangle.from_dir(dir)
	var desired := default.value + node_rotation.get_norm().value
	return Nangle.new(desired)

func radian_string(rad) -> String:
	if rad is float:
		return str(rad / PI) + " pi"
	elif rad is Nangle:
		return str(rad.value / PI) + " pi"
	elif rad is Fangle:
		return str(rad.get_value() / PI) + " pi"
	else:
		return "not a radian value"
