class_name ShipTester
extends Node2D

const RADIUS = 200
const SCALE = 100.0
const OFFSET = Vector2(300, 300)
const LEFT_POS = Vector2(0, 0)
const RIGHT_POS = Vector2(RADIUS, 0)

var grid: ShipGrid

var dragger: UserVelocityApplicator

func _init() -> void:
	var test_bp = "ddd\nddd\nddd"

	grid = ShipGridBuilder.debug_build(test_bp, OFFSET, SCALE)
	grid.soft_body.modules.add_modules_as_children_to(self)
	add_child(grid.soft_body)

	dragger = UserVelocityApplicator.new(grid.soft_body.modules)
	dragger.name = "dragger"
	add_child(dragger)


#    mods = ModuleMatrix.new(matrix)
#    dragger = UserVelocityApplicator.new(mods)
#    add_child(dragger)

func _physics_process(delta: float) -> void:
	grid.soft_body.manual_physics_process()