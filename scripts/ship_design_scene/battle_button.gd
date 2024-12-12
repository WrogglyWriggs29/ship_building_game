class_name BattleButton
extends Node2D

var width: float
var height: float

func _process(_delta: float) -> void:
	if width <= 0 or height <= 0:
		return
	queue_redraw()

func _draw() -> void:
	var button_rect = Rect2(Vector2.ZERO, Vector2(width, height))

	# draw fill
	draw_rect(button_rect, Color.CADET_BLUE)

	# draw borders
	draw_line(Vector2.ZERO, Vector2(width, 0), Color.BLACK)
	draw_line(Vector2(0, height), Vector2(width, height), Color.BLACK)
	draw_line(Vector2.ZERO, Vector2(0, height), Color.BLACK)
	draw_line(Vector2(width, 0), Vector2(width, height), Color.BLACK)

	var word_offset = Vector2(width / 2 - 30, height / 2 + 5)
	draw_string(ThemeDB.fallback_font, word_offset, "BATTLE")
