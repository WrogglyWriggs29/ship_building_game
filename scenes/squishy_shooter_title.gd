extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var background = $"Background(1)"

func _ready():
	pass


func _on_play_button_pressed() -> void:
	print("button pressed for play") # Replace with function body.
	
func _on_build_button_pressed() -> void:
	print("Buildbutton pressed")
	SceneManager.goto_ship_designer()
	
func _on_tutorial_button_pressed() -> void:
	print("tutorial pressed")
	SceneManager.goto_tutorial()
