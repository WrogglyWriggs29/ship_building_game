class_name GridSoftBody
extends Node

# note that this object is not a Node2D, as it does not have a position in the world
# it is a data structure that holds the modules and connections of a soft body grid
# and runs its physics simulation

var modules: ModuleMatrix
var connections: ConnectionMatrix