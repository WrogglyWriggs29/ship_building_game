class_name ShipGridBuilder
extends Object

# a factory that takes a blueprint object and creates a ship grid


# for easy testing, uses a simplified blueprint string format
# each row is separated by a newline
# each module is represented by a character
# connections are always assumed to exist for non-empty modules
# offset and scale are used to determine the starting position of each module
static func debug_build(blueprint_string: String, offset: Vector2, scale: float) -> ShipGrid:
    var modules = []
    var connections = []
    var index = Vector2i(0, 0)

    var rows = blueprint_string.split("\n")

    var module_row = []
    var connection_row1 = []
    var connection_row2 = []
    while true:
        if index.x >= rows[index.y].length():
            index.x = 0
            index.y += 1

            modules.push_back(module_row)
            connections.push_back(connection_row1)
            connections.push_back(connection_row2)
            module_row = []
            connection_row1 = []
            connection_row2 = []

        if index.y >= rows.size():
            break
        
        var module_char = rows[index.y][index.x]
        match module_char:
            "e":
                module_row.push_back(null)

                connection_row1.append_array([null, null])
                connection_row2.append_array([null, null])
            "d":
                var module = Module.new(Module.Type.DEBUG, position_from_index(index, scale) + offset)
                module.name = "debug" + str(id_from_index(index, rows[0].length()))

                print("Adding module " + module.name + " at " + str(module.position))
                module_row.push_back(module)

                connection_row1.append_array([Connection.basic_spring(scale), Connection.basic_spring(scale)])
                connection_row2.append_array([Connection.basic_spring(scale), Connection.basic_spring(scale)])
        index.x += 1

    return ShipGrid.new(ModuleMatrix.new(modules), ConnectionMatrix.new(connections))

static func build(bp: ShipGridBlueprint, offset: Vector2, scale: float) -> ShipGrid:
    var modules = []
    var connections = []
    for y in bp.height:
        var module_row = []
        var connection_row1 = []
        var connection_row2 = []
        for x in bp.width:
            var pair = bp.matrix.at(x, y)
            module_row.push_back(Module.new(bp.module_type_at(x, y), position_from_index(Vector2(x, y), scale) + offset))

            var cons: Array[bool] = bp.connections_at(x, y)
            connection_row1.push_back(null if not cons[0] else Connection.basic_spring(scale))
            connection_row1.push_back(null if not cons[1] else Connection.basic_spring(scale))
            connection_row2.push_back(null if not cons[3] else Connection.basic_spring(scale))
            connection_row2.push_back(null if not cons[2] else Connection.basic_spring(scale))

        modules.push_back(module_row)
        connections.push_back(connection_row1)
        connections.push_back(connection_row2)

    return ShipGrid.new(ModuleMatrix.new(modules), ConnectionMatrix.new(connections))

static func position_from_index(index: Vector2i, scale: float) -> Vector2:
    return Vector2(index.x * scale, index.y * scale)

static func id_from_index(index: Vector2i, row_size: int) -> int:
    return index.y * row_size + index.x