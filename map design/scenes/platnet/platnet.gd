@tool
class_name Planet
extends StaticBody2D

@export_range(100, 10000.0, 1, "or_greater") var radius: float = 200:
	set(v):
		radius = v
		if not is_instance_valid(_sprite):
			return
		#var prev := (_collision_shape.shape as CircleShape2D).radius
		#var sprite_scale := radius / prev
		#(_collision_shape.shape as CircleShape2D).radius *= sprite_scale
		#_sprite.scale *= sprite_scale
		#rotation = randf() * PI * 2.0


@export var _sprite: Sprite2D
#@export var _collision_shape :CollisionShape2D
@export var collision_polygon: CollisionPolygon2D

func _ready() -> void:
	radius = radius

func randomize_shape(min_radius: float, max_radius: float) -> void:
	radius = randf_range(min_radius, max_radius)
