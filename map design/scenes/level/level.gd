extends Area2D

const METEOR_SCENE = preload("../meteor/meteor.tscn")

@export var platnet_min_radius := 100
@export var platnet_max_radius := 300


@export var initial_meteors_area :CollisionShape2D

@export var meteor_min_radius := 2.0
@export var meteor_max_radius := 30.0
@export var meteor_amount := 100

@onready var _map_shape := $MapShape as CollisionShape2D


func _ready() -> void:
	body_exited.connect(_on_body_exited)
	_spread_meteors()


func _spread_meteors() -> void:
	var ctn := $Meteors

	var rect_shape :RectangleShape2D
	if is_instance_valid(initial_meteors_area):
		rect_shape = initial_meteors_area.shape as RectangleShape2D
		assert(is_instance_valid(rect_shape), "Only support use RectangleShape2D to configurate meteors' spawn area.")
	else:
		rect_shape = _map_shape.shape as RectangleShape2D
	var area_size: Vector2 = rect_shape.size
	var area_center_pos :Vector2 = _map_shape.global_position
	for _i in range(meteor_amount):
		var m := METEOR_SCENE.instantiate()
		m.randomize_shape(meteor_min_radius, meteor_max_radius)
		ctn.add_child(m)
		m.global_position = Vector2(randf() * area_size.x, randf() * area_size.y) + area_center_pos - area_size * 0.5


func _on_body_exited(body: Node2D) -> void:
	if not body is Meteor:
		return

	var rect_shape := _map_shape.shape as RectangleShape2D
	var size := rect_shape.size
	var pos := _map_shape.global_position
	body.global_position.x = wrapf(body.global_position.x, -size.x * 0.5 + pos.x, size.x * 0.5 + pos.x)
	body.global_position.y = wrapf(body.global_position.y, -size.y * 0.5 + pos.y, size.y * 0.5 + pos.y)
	body.force_update_transform()
