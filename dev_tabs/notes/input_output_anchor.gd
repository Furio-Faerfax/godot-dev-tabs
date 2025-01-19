extends Control

var _node_id: int:
	set(val): 
		_node_id = val

func _ready():
	_node_id = -1 

var type: String:
	set(val):
		name = val
		type = val

var is_connecting := false

func set_to_pos(vec) -> void:
	position = vec
