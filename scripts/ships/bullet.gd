class_name Bullet
extends Node2D

const FIRE_SPEED: float = 5.0
const mass = 4.5 * (3.0 / 4.0)

@export var lifetime: int = 400
var age: int = 0

var velocity: Vector2 = Vector2.ZERO


func _init(init_pos: Vector2, init_vel: Vector2, dir: Vector2) -> void:
	global_position = init_pos
	velocity = init_vel + dir * FIRE_SPEED

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 6, Color.CYAN)
	draw_circle(Vector2.ZERO, 3, Color.AZURE)

func manual_physics_process() -> void:
	age += 1
	global_position += velocity * GlobalConstants.TIME_STEP_CONSTANT

func is_dead() -> bool:
	return age >= lifetime

#func _process(delta: float) -> void:
	#_countdown += delta
	#if _countdown >= life_time:
	#	queue_free()
		
	# move_local_x(speed * delta)
	#var base_velocity = Vector2(cos(rotation), sin(rotation)) * speed
	#var total_velocity = base_velocity + velocity
	#position += total_velocity * delta

#func _on_body_entered(body: Node2D) -> void:
	#if owner_player == body:
	#	return

	#var p := body as Player
	#if is_instance_valid(p):
	#	p.take_damage(damage)
	#AudioManager.player_sfx("res://Audio/Impact/explodemini.wav")
	#queue_free()
