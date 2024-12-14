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

var ship1 : Ship
var ship2 : Ship
var camera : Camera2D
var not_setup = true

@export var base_zoom: float = 1.0  # Default zoom level
@export var max_zoom: float = 3.0  # Maximum zoom out
@export var min_zoom: float = 0.5  # Minimum zoom in
@export var zoom_distance_scale: float = 500.0  # Distance scaling factor for zoom
@export var camera_lerp_speed: float = 5.0  # Speed for smooth camera movement


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
			
	
	print(ship1.position, ship2.position)
	# Create and set up the camera
	camera = Camera2D.new()
	add_child(camera)
	camera.make_current()
	camera.zoom = Vector2(2, 2)  # Default zoom level (adjust as needed)

	not_setup = false

func _physics_process(_delta: float) -> void:
	if ship1 == null or ship2 == null:
		return

	# Update ships' physics
	ship1.manual_physics_process()
	ship2.manual_physics_process()

	# Update the camera position to follow both ships
	_update_camera(_delta)

func _update_camera(delta) -> void:
	# Calculate the midpoint between the two ships
	var midpoint = (ship1.get_average_position() + ship2.get_average_position()) / 2
	print("midpoint: ", midpoint)

	camera.position = lerp(camera.position, midpoint, delta * camera_lerp_speed)

	# Calculate the distance between the two ships
	var distance = ship1.global_position.distance_to(ship2.global_position)

	# Determine desired zoom level based on the distance
	var desired_zoom = base_zoom + (distance / zoom_distance_scale)
	desired_zoom = clamp(desired_zoom, min_zoom, max_zoom)

	# Smoothly adjust the zoom level
	camera.zoom = lerp(camera.zoom, Vector2(desired_zoom, desired_zoom), delta * camera_lerp_speed)
	
