extends Node2D

var start_playback = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Playerstate.isend == true:
		SceneStack.return_scene()
	if start_playback == true:
		DialogueManager.show_example_dialogue_balloon(load("res://dia.dialogue"), "first")
		start_playback = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SceneStack.return_scene()
