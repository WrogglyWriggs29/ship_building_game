class_name Player
extends CharacterBody2D


@export var input_mapping:InputMapping = preload("res://data/input_mappings/p1.tres")
@export var speed := 300.0
@export var acceleration := 600.0
@export var shoot_interval := 1.0
@export var max_hp := 100.0
@export var projectile_scene: PackedScene = preload("res://scenes/projectile/projectile.tscn")


@onready var _shoot_pos : Marker2D = %ShootPos

var hp := max_hp
var _shoot_cooldown_timer := -1.0


func _ready() -> void:
	hp = max_hp


func _physics_process(delta: float) -> void:
	if _shoot_cooldown_timer > 0.0:
		_shoot_cooldown_timer -= delta
	
	var direction := Input.get_vector(
		input_mapping.move_left,
		input_mapping.move_right,
		input_mapping.move_up,
		input_mapping.move_down
	)
	var target_velocity := direction * speed
	if direction.is_zero_approx():
		target_velocity = Vector2.ZERO
	velocity = velocity.move_toward(target_velocity, acceleration * delta)

	if not velocity.is_zero_approx():
		look_at(global_position + velocity)

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(input_mapping.fire) and _shoot_cooldown_timer <= 0.0:
		fire()


func fire() -> void:
	var bullet := projectile_scene.instantiate() as Node2D
	get_parent().add_child(bullet)
	bullet.global_transform = _shoot_pos.global_transform
	AudioManager.player_sfx("res://Audio/Gun/space laser.wav")
	_shoot_cooldown_timer = shoot_interval
	bullet.owner_player = self


func take_damage(damage: float) -> void:
	print(name, " take damage : ", damage)
	hp -= damage
	if hp <= 0.0:
		AudioManager.player_sfx("res://Audio/Meteorite&ship impact/explode.wav")
		queue_free()
