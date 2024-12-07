class_name Meteor
extends RigidBody2D


@export var _sprite :Sprite2D
@export var _collision_shape :CollisionShape2D

func randomize_shape(min_radius: float, max_radius: float) -> void:
	var prev := (_collision_shape.shape as CircleShape2D).radius
	var sprite_scale := randf_range(min_radius, max_radius) / prev
	(_collision_shape.shape as CircleShape2D).radius *= sprite_scale
	_sprite.scale *= sprite_scale
	rotation = randf() * PI * 2.0

	#mass = sprite_scale * 2.0
