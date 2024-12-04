class_name ToolPalette
extends Node2D

enum ToolType {PLACE, REMOVE}

class SelectionOptions:
    var options: Array[Rect2]

    func _init() -> void:
        options = []
    
    func check_selected(point: Vector2) -> int:
        for i in range(options.size()):
            if options[i].has_point(point):
                return i
        return -1
    
    func clear() -> void:
        options.clear()

    func push(rect: Rect2) -> void:
        options.push_back(rect)
    
    func count() -> int:
        return options.size()
    
    func at(index: int) -> Rect2:
        return options[index]


var sel_options: SelectionOptions = SelectionOptions.new()

var selected: int = 0

var width: float
var height: float

var placeholder_text = ["Place", "Remove"]

func _process(_delta: float) -> void:
    if width == 0 or height == 0:
        return
    if height > width:
        return
    

    var cell_size = Vector2(min(width / placeholder_text.size(), height), height)

    sel_options.clear()
    for i in range(placeholder_text.size()):
        var rect = Rect2(Vector2(i * cell_size.x, 0), cell_size)
        sel_options.push(rect)

    queue_redraw()

func _draw() -> void:
    for i in sel_options.count():
        var rect = sel_options.at(i)
        if i == selected:
            var color = Color.CADET_BLUE
            draw_rect(rect, color)
        draw_line(rect.position, rect.position + Vector2(0, rect.size.y), Color.CADET_BLUE)
        draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + rect.size.x / 4, rect.position.y + rect.size.y / 2), placeholder_text[i])

func select_at(point: Vector2) -> void:
    var index = sel_options.check_selected(point)
    if index != -1:
        selected = index
        queue_redraw()

static func type(index: int, layer: ShipBlueprintDesigner.Layer) -> ToolType:
    match layer:
        ShipBlueprintDesigner.Layer.STRUCTURE:
            match index:
                0:
                    return ToolType.PLACE
                1:
                    return ToolType.REMOVE
        ShipBlueprintDesigner.Layer.FACTORY:
            match index:
                0:
                    return ToolType.PLACE
                1:
                    return ToolType.REMOVE
    
    return ToolType.PLACE