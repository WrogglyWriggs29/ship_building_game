class_name ShipFightScene
extends Node2D

var ship1
var ship2

var cam1
var cam2

var not_setup = true
@onready var vp1 = $"SplitScreen/SubViewportContainer1/SubViewportP1"
@onready var vp2 = $"SplitScreen/SubViewportContainer2/SubViewportP2"

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if ship1 == null or ship2 == null:
		return
	elif not_setup:
		vp1.add_child(ship1)
		vp1.add_child(ship2)

		cam1 = ShipCamera.new(ship1)
		vp1.add_child(cam1)
		cam1.make_current()
		cam2 = ShipCamera.new(ship2)
		vp2.add_child(cam2)
		cam2.make_current()

		vp2.world_2d = vp1.world_2d
		not_setup = false


func _physics_process(_delta: float) -> void:
	assert(ship1 != null and ship2 != null, "This scene should be entered from ShipCombatScene")
	ship1.manual_physics_process()
	ship2.manual_physics_process()
