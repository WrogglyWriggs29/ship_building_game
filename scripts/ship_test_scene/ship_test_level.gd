extends Area2D

const METEOR_SCENE = preload("res://map_design/meteor/meteor.tscn")

const RADIUS = 200
const SCALE = 100.0
const OFFSET = Vector2(300, 300)
const LEFT_POS = Vector2(0, 0)
const RIGHT_POS = Vector2(RADIUS, 0)

# this should be initialized by the scene that uses this scene
var ship: Ship = null
var ship_camera: ShipCamera

var dragger: UserVelocityApplicator

var returner: SceneReturner = null

@export var platnet_min_radius := 100
@export var platnet_max_radius := 300


@export var initial_meteors_area: CollisionShape2D

@export var meteor_min_radius := 2.0
@export var meteor_max_radius := 30.0
@export var meteor_amount := 100

@onready var _map_shape := $MapShape as CollisionShape2D

func _ready() -> void:
	#var test_bp = ShipTester.make_test_bp()

	#var factory = ShipFactory.new()
	#add_child(factory)
	#ship = factory.from_grid(test_bp)
	ship.grids[0].soft_body.modules.add_modules_as_children_to(get_parent())
	add_child(ship.grids[0].soft_body)
	add_child(ship)

	ship_camera = ShipCamera.new(ship)
	add_child(ship_camera)
	ship_camera.make_current()

	var drag_modules = ship.grids[0].soft_body.modules
	dragger = UserVelocityApplicator.new(drag_modules, ship_camera)
	dragger.name = "dragger"
	add_child(dragger)

	_spread_meteors()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneStack.return_scene()

func _physics_process(_delta: float) -> void:
	ship.manual_physics_process() # grid.soft_body.manual_physics_process()

func _spread_meteors() -> void:
	var ctn := $Meteors

	var rect_shape: RectangleShape2D
	if is_instance_valid(initial_meteors_area):
		rect_shape = initial_meteors_area.shape as RectangleShape2D
		assert(is_instance_valid(rect_shape), "Only support use RectangleShape2D to configurate meteors' spawn area.")
	else:
		rect_shape = _map_shape.shape as RectangleShape2D
	var area_size: Vector2 = rect_shape.size
	var area_center_pos: Vector2 = _map_shape.global_position
	for _i in range(meteor_amount):
		var m := METEOR_SCENE.instantiate()
		m.randomize_shape(meteor_min_radius, meteor_max_radius)
		ctn.add_child(m)
		m.global_position = Vector2(randf() * area_size.x, randf() * area_size.y) + area_center_pos - area_size * 0.5