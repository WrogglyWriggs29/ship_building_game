class_name ShipFightScene
extends Node2D

var ship1
var ship2

var cont1: SubViewportContainer
var viewport1: SubViewport
var cam1: ShipCamera
var cont2: SubViewportContainer
var viewport2: SubViewport
var cam2: ShipCamera

func _ready() -> void:
    var dims = get_viewport().size

    cont1 = SubViewportContainer.new()
    cont1.position = Vector2(0, 0)
    cont1.size = Vector2(dims.x / 2, dims.y)
    add_child(cont1)
    viewport1 = SubViewport.new()
    cont1.add_child(viewport1)
    cam1 = ShipCamera.new(ship1)
    viewport1.add_child(cam1)

    viewport1.add_child(ship1)

    cont2 = SubViewportContainer.new()
    cont2.position = Vector2(dims.x / 2, 0)
    cont2.size = Vector2(dims.x / 2, dims.y)
    add_child(cont2)
    viewport2 = SubViewport.new()
    cont2.add_child(viewport2)
    cam2 = ShipCamera.new(ship2)
    viewport2.add_child(cam2)

    viewport2.add_child(ship2)


func _physics_process(delta: float) -> void:
    ship1.manual_physics_process()
    ship2.manual_physics_process()
