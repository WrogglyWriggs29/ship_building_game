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
		
	add_module_sprites()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			actions.trigger(event.keycode)
		else:
			actions.untrigger(event.keycode)

func manual_physics_process() -> void:
	for grid in grids:
		grid.manual_physics_process()
		
		update_sprites()

func get_average_position() -> Vector2:
	if grids.is_empty():
		return Vector2.ZERO

	var total_position = Vector2.ZERO
	var count = 0

	for grid in grids:
		var grid_position = grid.get_average_position()
		#print("avg: ", grid_position)
		if grid_position != Vector2.ZERO:
			total_position += grid_position
			count += 1
		#print("grid position of ", grid_position, " ", count)
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
					var rotation = module.phys_rotation.get_value() #- grid.rotation
					print("Rotation of module", rotation)
					print("Rotation of grid", grid.rotation)
					var combined_rotation = rotation # + Dir.to_angle(orientation)
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
		var grid = grids[0]  # Adjust if you have multiple grids
		var optional_module = grid.soft_body.modules.at(module_index.x, module_index.y)

		if optional_module.exists:
			var module = optional_module.module

			# Update sprite position and rotation
			sprite.position = module.global_position
			sprite.rotation = -module.phys_rotation.get_value()
	
	
	
	
	
