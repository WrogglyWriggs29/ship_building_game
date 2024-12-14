class_name Ship
extends Node2D

var actions: ActionBinder = ActionBinder.new()
var grids: Array[ShipGrid] = []
var sprites_by_module = {}

func _init(_grids: Array[ShipGrid], _actions) -> void:
	grids = _grids
	actions = _actions

func _ready() -> void:
	for grid in grids:
		add_child(grid)
		grid.soft_body.modules.add_modules_as_children_to(get_parent())
		add_sibling(grid.soft_body)
		
	add_module_sprites()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			actions.trigger(event.keycode)
		else:
			actions.untrigger(event.keycode)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	pass

func manual_physics_process() -> void:
	for i in grids.size():
		var grid = grids[i]
		var new_bullets: Array[Bullet] = []
		for bullet in grid.bullets:
			if not bullet.is_dead():
				new_bullets.push_back(bullet)
			else:
				bullet.queue_free()

		grid.bullets = new_bullets

		for j in grid.bullets.size():
			var bullet = grid.bullets[j]
			bullet.manual_physics_process()
		

		var dc: Array[DisconnectionEvent] = grid.manual_physics_process()
		var already_done = {}
		for event in dc:
			if already_done.has(event.hash()):
				continue
			else:
				already_done[event.hash()] = true

			print(grid.name_str() + "Disconnecting ", event.a, " and ", event.b)

			var cons = grid.soft_body.connections.connecting(event.a, event.b)
			grid.assert_valid_connection_pair(cons, event)

			grid.disconnect_cons(cons[0], cons[1])

			if grid.find_from(cons[0], cons[1]):
				# tell the two modules to recalculate their vertices that could be affected
				# we don't need to do this for a split because it clears the vertices completely
				var offset: Vector2i = event.b - event.a
				var dir := Dir.from_index_offset(offset)
				Dir.assert_dir(dir)

				var corner_a1 := CornerDir.corner_dir_counter_clockwise_from(dir)
				var corner_a2 := CornerDir.corner_dir_clockwise_from(dir)
				var corner_b1 := CornerDir.corner_dir_counter_clockwise_from(Dir.reverse(dir))
				var corner_b2 := CornerDir.corner_dir_clockwise_from(Dir.reverse(dir))

				var mod_a = grid.soft_body.modules.at_index(event.a).module
				var mod_b = grid.soft_body.modules.at_index(event.b).module

				mod_a.vertices[corner_a1] = SharedVector.new()
				mod_a.vertices[corner_a2] = SharedVector.new()
				mod_b.vertices[corner_b1] = SharedVector.new()
				mod_b.vertices[corner_b2] = SharedVector.new()

			else:
				print("Grid split detected.")
				var new_grids: Array[ShipGrid] = split_grid(grid.mod_of_con(cons[0]), grid.mod_of_con(cons[1]), grid)
				for new_grid in new_grids:
					new_grid.clear_vertices()
					grids.push_back(new_grid)
					add_child(new_grid)
				remove_child(grid)
				grids.remove_at(i)
				i -= 1
				# we don't want to process the other disconnections on the old grid
				break

	update_sprites()

# create two new equally sized blank grids, one for each side of the disconnection, 
# then copy the modules and connections from the original grid to the new grids in a tree search
func split_grid(a: Vector2i, b: Vector2i, grid: ShipGrid) -> Array[ShipGrid]:
	var grid_a = ShipGridBuilder.tree_copy_existing(grid, a)
	var grid_b = ShipGridBuilder.tree_copy_existing(grid, b)

	return [grid_a, grid_b]

func get_average_position() -> Vector2:
	if grids.is_empty():
		return Vector2.ZERO

	var total_position = Vector2.ZERO
	var count = 0

	for grid in grids:
		var avg_data: Array = grid.get_position_sum()
		total_position += avg_data[0]
		count += avg_data[1]

	if count == 0:
		return Vector2.ZERO
	return total_position / count
	
func add_module_sprites() -> void:
	# Iterate through each grid and its modules
	for grid in grids:
		#modules is a module_matrix, (2d so we have to do x and y)
		for x in range(grid.soft_body.modules.height):
			for y in range(grid.soft_body.modules.width):
				var optional_module = grid.soft_body.modules.at(x, y)
				var module_index = Vector2i(x, y)
				if optional_module.exists:
					var module = optional_module.module
					var position = module.phys_position
					var scale = Vector2(1.5, 1.5)
					var orientation = grid.factory.modules.at(x, y).part.orientation
					var rotation = module.phys_rotation.get_value() # - grid.rotation
					var combined_rotation = rotation + Dir.to_angle(orientation)
					if grid.is_thruster(Vector2i(x, y)):
						# Add sprite for thruster
						var thruster_sprite = Sprite2D.new()
						thruster_sprite.texture = preload("res://assets/images/thrusters.png")
						thruster_sprite.position = position
						thruster_sprite.scale = scale
						thruster_sprite.rotation = combined_rotation
						add_child(thruster_sprite)
						sprites_by_module[module_index] = thruster_sprite
					elif grid.is_gun(Vector2i(x, y)):
						# Add sprite for gun
						var gun_sprite = Sprite2D.new()
						gun_sprite.texture = preload("res://assets/images/gun.png")
						gun_sprite.position = position
						gun_sprite.scale = scale
						gun_sprite.rotation = combined_rotation
						add_child(gun_sprite)
						sprites_by_module[module_index] = gun_sprite
					

func update_sprites() -> void:
	for module_index in sprites_by_module.keys():
		# Retrieve the sprite and corresponding module
		var sprite = sprites_by_module[module_index]
		var grid = grids[0] # Adjust if you have multiple grids
		if not grid.soft_body.modules.in_range(module_index):
			continue
		var optional_module = grid.soft_body.modules.at(module_index.x, module_index.y)
		var optional_part = grid.factory.modules.at(module_index.x, module_index.y)
		
		if optional_module.exists and optional_part.exists:
			var module = optional_module.module
			var part = optional_part.part

			# don't ask me why this works
			var orientation_angle = Dir.to_angle(Dir._clockwise_dirs[Dir.reverse(part.orientation)])
			var desired_angle = -module.phys_rotation.get_norm().value - orientation_angle
			var vec = Vector2.RIGHT.rotated(desired_angle)
			var angle = -vec.angle_to(Vector2.RIGHT)
			angle += PI

			var action_on = part.action_is_on

			sprite.position = module.global_position
			sprite.rotation = angle

			match part.type:
				GridFactory.FactoryPartState.Type.GUN:
					match action_on:
						true:
							sprite.texture = preload("res://assets/images/gun_fired.png")
						false:
							sprite.texture = preload("res://assets/images/gun.png")
				GridFactory.FactoryPartState.Type.THRUSTER:
					match action_on:
						true:
							sprite.texture = preload("res://assets/images/thrusters_fired.png")
						false:
							sprite.texture = preload("res://assets/images/thrusters.png")
