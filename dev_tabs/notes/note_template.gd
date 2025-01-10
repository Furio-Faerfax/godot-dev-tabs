extends Node2D


@onready var note_template: Node2D = $"."
@onready var connections: Node2D = $container/connector/connections
@onready var connections_field: Node2D = %connections_field
@onready var anchor_collector: Node2D = $container/connector/anchors/anchor_collector
@onready var input_output_tmp: Node = $container/connector/input_output_tmp

@export var field_bg: ColorRect
@export var connections_received: Array
@export var connections_sended: Array
@export var connected_over: Array

const NODE_CONNECTION = preload("res://dev_tabs/notes/node_connection.tscn")
const INPUT_ANCHOR = preload("res://dev_tabs/notes/input_anchor.tscn")
const OUTPUT_ANCHOR = preload("res://dev_tabs/notes/output_anchor.tscn")

var note_drag = false
var offset = Vector2()

var node_type = "note"
var _node_id := -1
var connect_to_id = -1

var connecting = false
var self_connect  = false
var can_connect = false
var check_last = false
var input: ColorRect
var output: ColorRect

var new_connection = []

func _ready() -> void:
	Settings.connection_area_entered.connect(connection_entered_area)
	Settings.connection_area_exited.connect(connection_exited_area)


func _process(_delta: float) -> void:
	if note_drag:
		note_template.position = field_bg.get_local_mouse_position()+offset
		for connection in connected_over:
			connection.adjust_target()
		
	#print(self_connect, " ",connecting, " ",can_connect)
	if self_connect:
		if connecting:
			input.set_to_pos(get_local_mouse_position())
		else:
			pass

func _on_area_gui_input(event: InputEvent, _area: String) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 1 and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				connecting = true
				self_connect = true
				
				var inst = NODE_CONNECTION.instantiate()
				
				
				input = INPUT_ANCHOR.instantiate()
				input.type = "input"
				input._node_id = self._node_id
				output = OUTPUT_ANCHOR.instantiate()
				output.type = "output"
				output._node_id = self._node_id
				
				output.position = get_local_mouse_position()
				
				
				input_output_tmp.add_child(input)
				input_output_tmp.add_child(output)
				
				inst.is_connecting = true
				inst.output = output
				inst.input = input
				inst.note_1 = self
				connections.add_child(inst)
				
				new_connection.push_back(inst)
				new_connection.push_back(output)
				new_connection.push_back(input)
		if not event.pressed:
			
			connecting = false
			self_connect = false
			
			var temp_id = null
			if connect_to_id == -1:
				temp_id = self
			else:
				temp_id = instance_from_id(connect_to_id)
				
			if temp_id._node_id == self._node_id or temp_id._node_id == -1:
				#print(new_connection)
				if new_connection.size() > 0: 
					for each in new_connection.size():
						new_connection[each].queue_free()
					new_connection = []
			else:
				var other = instance_from_id(connect_to_id)
				output.reparent(self.anchor_collector)
				input.reparent(other.anchor_collector)
				connected_over.push_back(new_connection[0])
				other.connected_over.push_back(new_connection[0])
				new_connection[0].is_connecting = false
				new_connection[0].note_2 = other
				new_connection = []
				output = null
				input = null

func _on_button_pressed() -> void:
	queue_free()
	
#region dragging function
func _on_note_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			if event.button_index == MOUSE_BUTTON_LEFT:
				note_drag = true
				offset = self.position-field_bg.get_local_mouse_position()
			if not event.pressed:
				note_drag = false
#endregion

#region signal connections
func connection_entered_area(id_connect: int, _area: String):
	if connecting:
		connect_to_id = id_connect
		#print("Connecting Note: ", self._node_id, " to: ", instance_from_id(connect_to_id)._node_id)

func connection_exited_area(id_connect: int, _area: String):
	if connect_to_id != -1 and  not connecting:
		connect_to_id = id_connect
		connect_to_id = -1
		#print(connect_to_id)

func _on_right_gui_input(event: InputEvent) -> void:
	_on_area_gui_input(event, "right")

func _on_down_gui_input(event: InputEvent) -> void:
	_on_area_gui_input(event, "bot")

func _on_top_gui_input(event: InputEvent) -> void:
	_on_area_gui_input(event, "top")

func _on_left_gui_input(event: InputEvent) -> void:
	_on_area_gui_input(event, "left")




func _on_left_mouse_entered() -> void:
	can_connect = true
	Settings.connection_area_entered.emit(get_instance_id(), "left")

func _on_top_mouse_entered() -> void:
	can_connect = true
	Settings.connection_area_entered.emit(get_instance_id(), "top")

func _on_down_mouse_entered() -> void:
	can_connect = true
	Settings.connection_area_entered.emit(get_instance_id(), "bot")

func _on_right_mouse_entered() -> void:
	can_connect = true
	Settings.connection_area_entered.emit(get_instance_id(), "right")

func _on_right_mouse_exited() -> void:
	Settings.connection_area_exited.emit(-1, "right")
	if !connecting:
		self_connect = false
	
func _on_top_mouse_exited() -> void:
	Settings.connection_area_exited.emit(-1, "top")
	if !connecting:
		self_connect = false
		
func _on_down_mouse_exited() -> void:
	Settings.connection_area_exited.emit(-1, "bot")
	if !connecting:
		self_connect = false

func _on_left_mouse_exited() -> void:
	Settings.connection_area_exited.emit(-1, "left")
	if !connecting:
		self_connect = false
#endregion
