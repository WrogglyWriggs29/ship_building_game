class_name ConnectionMatrix
extends Node

# connections are stored as such:
# for a module like 
#   A
# D o B
#   C
# the connections are stored as
#  A B 
#  D C
# in the matrix

# this means the connection matrix should be twice as wide and tall as the module matrix

var connections: Matrix