extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	DialogueManager.show_example_dialogue_balloon(load("res://dia.dialogue"),"first")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Playerstate.isend==true:
		get_tree().change_scene_to_file("res://scenes/squishy_shooter_title.tscn") #("res://ship_test_level.tscn")
