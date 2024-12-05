class_name LayerSelector
extends Node2D

const DESIRED_TAB_WIDTH: int = 150

var width: float
var height: float
var selected: ShipBlueprintDesigner.Layer

func _init() -> void:
    selected = ShipBlueprintDesigner.Layer.STRUCTURE

func _process(_delta: float) -> void:
    if width <= 0 or height <= 0:
        return
    queue_redraw()

func _draw() -> void:
    const unsel_color = Color.DARK_GRAY
    const sel_color = Color.CADET_BLUE

    var structure_label_width = min(DESIRED_TAB_WIDTH, width / 2)

    var structure_label_rect = Rect2(Vector2.ZERO, Vector2(structure_label_width, height))

    var factory_label_top_left = Vector2(structure_label_width, 0)
    var factory_label_rect = Rect2(factory_label_top_left, Vector2(width - structure_label_width, height))

    draw_rect(structure_label_rect, sel_color if selected == ShipBlueprintDesigner.Layer.STRUCTURE else unsel_color)
    draw_rect(factory_label_rect, sel_color if selected == ShipBlueprintDesigner.Layer.FACTORY else unsel_color)

    var word_offset = Vector2(30, height / 2 + 5)
    draw_string(ThemeDB.fallback_font, word_offset, "Structure (1)")
    draw_string(ThemeDB.fallback_font, factory_label_rect.position + word_offset, "Factory (2)")

    # top and bottom
    draw_line(Vector2(0, 0), Vector2(width, 0), Color.BLACK)
    draw_line(Vector2(0, height), Vector2(width, height), Color.BLACK)
    # seperator line
    draw_line(Vector2.ZERO, Vector2(0, height), Color.BLACK)
    draw_line(Vector2(structure_label_width, 0), Vector2(structure_label_width, height), Color.BLACK)
    #draw_line(factory_label_top_left, factory_label_top_left + Vector2(0, height), Color.BLACK)

func select_at(point: Vector2) -> void:
    if point.x < 0 or point.x > width or point.y < 0 or point.y > height:
        return
    
    var structure_label_width = min(DESIRED_TAB_WIDTH, width / 2)
    if point.x < structure_label_width:
        selected = ShipBlueprintDesigner.Layer.STRUCTURE
    else:
        selected = ShipBlueprintDesigner.Layer.FACTORY
    queue_redraw()