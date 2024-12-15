class_name ShipFightScene
extends Node2D

#var ship1
#var ship2
#
#var cam1
#var cam2
#
#var not_setup = true
#@onready var vp1 = $"SplitScreen/SubViewportContainer1/SubViewportP1"
#@onready var vp2 = $"SplitScreen/SubViewportContainer2/SubViewportP2"
#
#func _ready() -> void:
	#pass
#
#func _process(_delta: float) -> void:
	#if ship1 == null or ship2 == null:
		#return
	#elif not_setup:
		#vp1.add_child(ship1)
		#vp1.add_child(ship2)
#
		#cam1 = ShipCamera.new(ship1)
		#vp1.add_child(cam1)
		#cam1.make_current()
		#cam2 = ShipCamera.new(ship2)
		#vp2.add_child(cam2)
		#cam2.make_current()
#
		#vp2.world_2d = vp1.world_2d
		#not_setup = false
#
#
#func _physics_process(_delta: float) -> void:
	#assert(ship1 != null and ship2 != null, "This scene should be entered from ShipCombatScene")
	#ship1.manual_physics_process()
	#ship2.manual_physics_process()
#

var ship1: Ship
var ship2: Ship
var camera: MultiShipCamera
var not_setup = true

@export var base_zoom: float = 1.0 # Default zoom level
@export var max_zoom: float = 3.0 # Maximum zoom out
@export var min_zoom: float = 0.5 # Minimum zoom in
@export var zoom_distance_scale: float = 500.0 # Distance scaling factor for zoom
@export var camera_lerp_speed: float = 5.0 # Speed for smooth camera movement


func _ready() -> void:
	# Initialize ships (these should be set externally before entering the scene)
	assert(ship1 != null and ship2 != null, "Ships must be set before entering ShipFightScene")

	# Add ships to the scene
	add_child(ship1)
	add_child(ship2)
	
	
	for grid in ship1.grids:
		for x in range(grid.soft_body.modules.height):
			for y in range(grid.soft_body.modules.width):
				var optional_module = grid.soft_body.modules.at(x, y)
				var module_index = Vector2i(x, y)
				if optional_module.exists:
					var module = optional_module.module
					module.phys_position -= Vector2(150, 0)
	
	for grid in ship2.grids:
		for x in range(grid.soft_body.modules.height):
			for y in range(grid.soft_body.modules.width):
				var optional_module = grid.soft_body.modules.at(x, y)
				var module_index = Vector2i(x, y)
				if optional_module.exists:
					var module = optional_module.module
					module.phys_position += Vector2(150, 0)
			
	
	camera = MultiShipCamera.new([ship1, ship2])
	add_child(camera)
	camera.make_current()


	not_setup = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneStack.return_scene()

func _physics_process(_delta: float) -> void:
	if ship1 == null or ship2 == null:
		return
	# Update ships' physics
	ship1.manual_physics_process()
	ship2.manual_physics_process()

	var p1_bullets = []
	var p2_bullets = []

	for grid in ship1.grids:
		for bullet in grid.bullets:
			p1_bullets.append(bullet)
	for grid in ship2.grids:
		for bullet in grid.bullets:
			p2_bullets.append(bullet)
	
	var collider: ShipGrid.CollisionPolygon
	for grid in ship1.grids:
		collider = grid.collider
		for bullet in p2_bullets:
			if collider.may_collide_point(bullet.global_position):
				if Geometry2D.is_point_in_polygon(bullet.global_position, collider.get_polygon()):
					hit_grid_with_bullet(grid, bullet)
		
		for enemy_grid in ship2.grids:
			if ShipGrid.CollisionPolygon.may_collide(collider, enemy_grid.collider):
				grid.collide(enemy_grid.collider.get_polygon())
				enemy_grid.collide(collider.get_polygon())
	
	for grid in ship2.grids:
		collider = grid.collider
		for bullet in p1_bullets:
			if collider.may_collide_point(bullet.global_position):
				if Geometry2D.is_point_in_polygon(bullet.global_position, collider.get_polygon()):
					hit_grid_with_bullet(grid, bullet)

func hit_grid_with_bullet(grid: ShipGrid, bullet: Bullet) -> void:
	var pos = bullet.global_position
	var col = grid.collider
	var vertex = col.closest_shared(pos)
	if vertex.held_by.size() != 0:
		var nearest: Vector2 = closest_point_on_polygon_from(pos, col.get_polygon())

		var backout_path = nearest - pos

		var distance_out = backout_path.length()

		var speed = distance_out / GlobalConstants.TIME_STEP_CONSTANT

		var accel = backout_path.normalized() * speed

		AudioManager.player_sfx("res://Audio/Impact/explodemini.wav")
		bullet.velocity += accel * bullet.mass
		accel /= vertex.held_by.size()
		for mod in vertex.held_by:
			mod.apply_accel(-accel * bullet.mass)

func closest_point_on_polygon_from(pos: Vector2, poly: PackedVector2Array) -> Vector2:
	var closest = poly[0]
	var closest_dist = closest.distance_to(pos)
	for i in range(1, poly.size()):
		var close = Geometry2D.get_closest_point_to_segment(pos, poly[i - 1], poly[i])
		if close.distance_to(pos) < closest_dist:
			closest = close
			closest_dist = close.distance_to(pos)
	return closest