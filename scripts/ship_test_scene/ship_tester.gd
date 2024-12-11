class_name ShipTester
extends Node2D

const RADIUS = 200
const SCALE = 100.0
const OFFSET = Vector2(300, 300)
const LEFT_POS = Vector2(0, 0)
const RIGHT_POS = Vector2(RADIUS, 0)

var ship: Ship
var ship_camera: ShipCamera

var dragger: UserVelocityApplicator

static func make_test_bp() -> ShipGridBlueprint:
	var matrix = []
	#var bp = ShipGridBlueprint.new()
	for y in range(4):
		var row = []
		for x in range(4):
			var structure = StructureBlueprint.new(StructureBlueprint.Type.DEBUG)
			for dir in Dir.MAX:
				structure.connections[dir] = true
			var part = FactoryPartBlueprint.new(FactoryPartBlueprint.Type.DEBUG, Dir.UP, Inventory.new())
			row.push_back(ShipGridBlueprint.BlueprintPair.new(structure, part))
		matrix.push_back(row)
	
	matrix[3][1].part.type = FactoryPartBlueprint.Type.THRUSTER
	matrix[3][1].part.orientation = Dir.UP

	matrix[3][2].part.type = FactoryPartBlueprint.Type.THRUSTER
	matrix[3][2].part.orientation = Dir.UP

	matrix[0][0].part.type = FactoryPartBlueprint.Type.THRUSTER
	matrix[0][0].part.orientation = Dir.RIGHT

	matrix[3][0].part.type = FactoryPartBlueprint.Type.THRUSTER
	matrix[3][0].part.orientation = Dir.RIGHT

	matrix[0][3].part.type = FactoryPartBlueprint.Type.THRUSTER
	matrix[0][3].part.orientation = Dir.LEFT

	matrix[3][3].part.type = FactoryPartBlueprint.Type.THRUSTER
	matrix[3][3].part.orientation = Dir.LEFT

	matrix[0][1].part.type = FactoryPartBlueprint.Type.THRUSTER
	matrix[0][1].part.orientation = Dir.DOWN
	matrix[0][2].part.type = FactoryPartBlueprint.Type.THRUSTER
	matrix[0][2].part.orientation = Dir.DOWN

	var bp = ShipGridBlueprint.new(matrix)
	bp.actions[KEY_UP] = [Vector2i(1, 3), Vector2i(2, 3)]
	bp.actions[KEY_RIGHT] = [Vector2i(0, 0), Vector2i(3, 3)]
	bp.actions[KEY_LEFT] = [Vector2i(3, 0), Vector2i(0, 3)]
	bp.actions[KEY_DOWN] = [Vector2i(1, 0), Vector2i(2, 0)]
	return bp


func _init() -> void:
	#var test_bp = "dddd\ndddd\ndddd\ndddd"
	var test_bp = make_test_bp()

	var grid = ShipGridBuilder.build(test_bp, OFFSET, SCALE)

	grid.soft_body.modules.add_modules_as_children_to(self)
	add_child(grid.soft_body)

	ship = Ship.new([grid], ActionBinder.new())
	for key in test_bp.actions.keys():
		var action_indices = test_bp.actions[key]
		for index in action_indices:
			ship.actions.bind(key, grid.factory.modules.at_index(index))


	ship_camera = ShipCamera.new(ship)
	add_child(ship_camera)
	ship_camera.make_current()

	dragger = UserVelocityApplicator.new(grid.soft_body.modules, ship_camera)
	dragger.name = "dragger"
	add_child(dragger)

	add_child(ship)


#    mods = ModuleMatrix.new(matrix)
#    dragger = UserVelocityApplicator.new(mods)
#    add_child(dragger)

func _physics_process(_delta: float) -> void:
	ship.manual_physics_process() # grid.soft_body.manual_physics_process()
