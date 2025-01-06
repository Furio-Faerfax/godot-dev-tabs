extends Node2D
@export var field_bg: ColorRect


@export var connections_received: Array
@export var connections_sended: Array
@export var connected_over: Array

const NODE_CONNECTION = preload("res://dev_tabs/notes/node_connection.tscn")
const INPUT_ANCHOR = preload("res://dev_tabs/notes/input_anchor.tscn")
const OUTPUT_ANCHOR = preload("res://dev_tabs/notes/output_anchor.tscn")

@onready var connections: Node2D = $container/connector/connections
@onready var temp: Node2D = $container/connector/anchors/temp

@onready var anchors_collector: Node2D = $container/connector/anchors/anchors_collector
@onready var note_template: Node2D = $"."
var note_drag = false
var offset = Vector2()
var node_id := 0

var connecting = false
var self_connect  = false
var input: ColorRect
var output: ColorRect
var node_type2 = "note"
var connect_to_id = -1
var can_connect = false
var check_last = false


func _ready() -> void:
	Settings.connection_area_entered.connect(connection_entered_area)
	Settings.connection_area_exited.connect(connection_exited_area)


func _process(_delta: float) -> void:
	if note_drag:
		note_template.position = field_bg.get_local_mouse_position()+offset
		

	if self_connect:
		if connecting:
			pass
		else:
			pass

func _on_area_gui_input(event: InputEvent, _area: String) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			if event.button_index == MOUSE_BUTTON_LEFT:
				pass
		if not event.pressed:
			connecting = false

func _on_button_pressed() -> void:
	queue_free()
	
#region dragging function
func _on_note_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			if event.button_index == MOUSE_BUTTON_LEFT:
				note_drag = true
				offset = note_template.position-field_bg.get_local_mouse_position()
			if not event.pressed:
				note_drag = false
#endregion

#region signal connections
func connection_entered_area(id_connect: int, _area: String):
	if connecting:
		connect_to_id = id_connect

func connection_exited_area(id_connect: int, _area: String):
	if connect_to_id != -1 and  not connecting:
		connect_to_id = id_connect

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
