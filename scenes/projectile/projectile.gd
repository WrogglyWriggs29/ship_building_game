extends Area2D


@export var speed := 600.0
@export var damage := 25.0
@export var life_time := 5.0

var owner_player : Player

var _countdown := 0.0

func _init() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_countdown += delta
	if _countdown >= life_time:
		queue_free()
	move_local_x(speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if owner_player == body:
		return

	var p := body as Player
	if is_instance_valid(p):
		p.take_damage(damage)
	AudioManager.player_sfx("res://Audio/Impact/explodemini.wav")
	queue_free()
