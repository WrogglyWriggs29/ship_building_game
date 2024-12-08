extends Node

@export var view_port_p1: SubViewport
@export var view_port_p2 : SubViewport

func _ready() -> void:
	view_port_p2.world_2d = view_port_p1.world_2d
