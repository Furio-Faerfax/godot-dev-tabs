extends Node2D


@onready var container: Control = $container
@onready var note_template: Node2D = $"."
@onready var connections: Node2D = $container/connector/connections
@onready var connections_fiesld: Node2D
@onready var anchor_collector: Node2D = $container/connector/anchors/anchor_collector
@onready var input_output_tmp: Node = $container/connector/input_output_tmp
@onready var resizer: ColorRect = $container/resizer
@onready var note_bg_: ColorRect = $container/note_bg

@onready var color_picker_button: ColorPickerButton = $container/VBoxContainer/note_bar/note_bar/ColorPickerButton
@onready var note_content: ColorRect = $container/VBoxContainer/note_content

@onready var left_anchor: ColorRect = $container/connector/anchors/left
@onready var top_anchor: ColorRect = $container/connector/anchors/top
@onready var down_anchor: ColorRect = $container/connector/anchors/down
@onready var right_anchor: ColorRect = $container/connector/anchors/right

@onready var note_bar: HBoxContainer = $container/VBoxContainer/note_bar/note_bar
@onready var title_label: Label = $container/VBoxContainer/note_bar/note_bar/title
@onready var close: Button = $container/VBoxContainer/note_bar/note_bar/close

@export var field_bg: ColorRect
@export var connections_received: Array
@export var connections_sended: Array
@export var connected_over: Array


const NODE_CONNECTION = preload("res://dev_tabs/notes/node_connection.tscn")
const INPUT_ANCHOR = preload("res://dev_tabs/notes/input_anchor.tscn")
const OUTPUT_ANCHOR = preload("res://dev_tabs/notes/output_anchor.tscn")

var color_choose := false
var note_drag = false
var offset = Vector2()

var note_type = "note_template"
var _node_id := -1
var connect_to_id = -1

var connecting = false
var self_connect  = false
var can_connect = false
var check_last = false
var input: ColorRect
var output: ColorRect

var new_connection = []

var title := ""
var _path := ""
var text := ""
var _color := Color(0.227,0.227,0.227,1)
var _size: Vector2:
	set(val):
		_size = val
		if container:
			container.size = val

var can_resize := false
var resize := false

func _ínit():
	pass
func init():
	pass

func get_data() -> String:
	note_content.fill_data()
	var data_str = "type:"+str(note_type)+"|id:"+str(_node_id)+"|position:"+str(position.x)+"_"+str(position.y)+"|size:"+str(_size.x)+"_"+str(_size.y)+"|title:"+str(title)+"|text:"+str(text)+"|path:"+str(_path)+"|color:"+str(_color.r)+"_"+str(_color.g)+"_"+str(_color.b)+"_"+str(_color.a)
	return data_str

func _ready() -> void:
	if _size == Vector2():
		_size = container.size
	Settings.connection_area_entered.connect(connection_entered_area)
	Settings.connection_area_exited.connect(connection_exited_area)
	
	note_bg_.size = resizer.position+resizer.size-Vector2(10,10)
	update_data()

func _process(_delta: float) -> void:
	if note_drag:
		note_template.position = field_bg.get_local_mouse_position()+offset
		for connection in connected_over.size():
			if connected_over[connection] == null:
				connected_over.pop_at(connection)
				break
			connected_over[connection].adjust_target()
		
	if self_connect:
		if connecting:
			
			input.set_to_pos(get_local_mouse_position())
		else:
			pass
	
	if resize:
		resizing()
	
func _set_title(title_: String):
	await ready
	title_label.text = title_
## For loading the notes
func update_data():
	get_node("container").size = _size
	
	change_colors(_color)
	
	title_label.text = str(title)
	resizer.position = _size+Vector2(180,140)#Dont know why this works this way

	if note_content.get_child_count() > 0:
		note_content.update_data()
	resizing()
	
func _on_area_gui_input(event: InputEvent, _area: String) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 1 and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				Settings.mouse_note_connection_cursor_active = get_node("container/connector/anchors/"+str(_area))
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
			#print("YOO, connect to ID:", connect_to_id, ", self: ", get_instance_id())
			#if !wait_for_signal_exited.is_stopped():
				#await wait_for_signal_exited.timeout
			if !Settings.mouse_in_note_connection_border:
				pass #?
				#connect_to_id = -1
			if Settings.mouse_note_connection_cursor_active != null:
				Settings.mouse_note_connection_cursor_active.set_default_cursor_shape(Control.CURSOR_ARROW)
				Settings.mouse_note_connection_cursor_active = null
			connecting = false
			self_connect = false
			
			var temp_id = null
			if connect_to_id == -1:
				temp_id = self
			else:
				temp_id = instance_from_id(connect_to_id)
				
			if temp_id._node_id == self._node_id or temp_id._node_id == -1:
				#print(new_connection)
				#print(temp_id._node_id, ", ", _node_id)
				if new_connection.size() > 0: 
					for each in new_connection.size():
						new_connection[each].queue_free()
					new_connection = []
			else:
				var other = instance_from_id(connect_to_id)
				output.reparent(self.anchor_collector)
				input.reparent(other.anchor_collector)
				connected_over.push_back(new_connection[0])
				connections_sended.push_back(other._node_id)
				other.connected_over.push_back(new_connection[0])
				
				new_connection[0].is_connecting = false
				new_connection[0].note_2 = other
				new_connection = []
				output = null
				input = null

func _on_button_pressed() -> void:
	queue_free()
	pass
	
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


## The cursor of the Mouse, gives an visual feedback if it could connect to the note
#region signal connections
func connection_entered_area(id_connect: int, _area: String):
	#print("ENTERED: ", id_connect)
	if connecting:
		connect_to_id = id_connect
		#print("Connecting Note: ", self._node_id, " to: ", instance_from_id(connect_to_id)._node_id)

func connection_exited_area(id_connect: int, _area: String):
	#print("EXITED: ", id_connect)
	
	if connect_to_id != -1 and  not connecting:
		connect_to_id = id_connect
		connect_to_id = -1
		#print(connect_to_id)

func _on_right_gui_input(event: InputEvent) -> void:
	_on_area_gui_input(event, "right")

func _on_down_gui_input(event: InputEvent) -> void:
	_on_area_gui_input(event, "down")

func _on_top_gui_input(event: InputEvent) -> void:
	_on_area_gui_input(event, "top")

func _on_left_gui_input(event: InputEvent) -> void:
	_on_area_gui_input(event, "left")



func _on_left_mouse_entered() -> void:
	_on_enter_connector("left")

func _on_top_mouse_entered() -> void:
	_on_enter_connector("top")

func _on_down_mouse_entered() -> void:
	_on_enter_connector("down")
	
func _on_right_mouse_entered() -> void:
	_on_enter_connector("right")


func _on_right_mouse_exited() -> void:
	_on_exit_connector("right")
	
func _on_top_mouse_exited() -> void:
	_on_exit_connector("top")
		
func _on_down_mouse_exited() -> void:
	_on_exit_connector("down")

func _on_left_mouse_exited() -> void:
	_on_exit_connector("left")


func _on_enter_connector(side):
	can_connect = true
	#Settings.connection_area_entered.emit(_node_id, side)
	Settings.connection_area_entered.emit(get_instance_id(), side)
	Settings.mouse_in_note_connection_border = true
	if Settings.mouse_note_connection_cursor == null:
		Settings.mouse_note_connection_cursor = get_node("container/connector/anchors/"+str(side))
	if Settings.mouse_note_connection_cursor_active != null:
		Settings.mouse_note_connection_cursor_active.set_default_cursor_shape(Control.CURSOR_CROSS)
	else:
		Settings.mouse_note_connection_cursor.set_default_cursor_shape(Control.CURSOR_CROSS)

func _on_exit_connector(side):
	Settings.connection_area_exited.emit(-1, side)
	if !connecting:
		self_connect = false

	if Settings.mouse_note_connection_cursor != null:
		Settings.mouse_note_connection_cursor.set_default_cursor_shape(Control.CURSOR_ARROW)
		if Settings.mouse_note_connection_cursor_active != null:
			Settings.mouse_note_connection_cursor_active.set_default_cursor_shape(Control.CURSOR_ARROW)
		Settings.mouse_note_connection_cursor = null
	
	Settings.mouse_in_note_connection_border = false

func _on_resizer_gui_input(event: InputEvent) -> void:
	if can_resize:
		if event is InputEventMouseButton:
			if event.get_button_index() == 1:
				if event.is_action_pressed("mouse_left_dev_tabs"):
					resize = true
				if event.is_action_released("mouse_left_dev_tabs"):
					resize = false

func _on_resizer_mouse_entered() -> void:
	can_resize = true

func _on_resizer_mouse_exited() -> void:
	can_resize = true
#endregion

func resizing():
	resizer.position = get_local_mouse_position()-resizer.size/2
	self._size = resizer.position-Vector2(180,140)#Dont know why this works this way
	if self._size.x < 100:
		resizer.position.x = 285-resizer.size.x/2
		self._size.x = 100
	if self._size.y < 100:
		resizer.position.y = 250-resizer.size.y/2
		self._size.y = 100
		
	right_anchor.size.y = resizer.position.y+resizer.size.y
	right_anchor.position.x = resizer.position.x+resizer.size.x/2
	left_anchor.size.y = resizer.position.y+resizer.size.y
	
	down_anchor.size.x = resizer.position.x+resizer.size.x
	down_anchor.position.y = resizer.position.y+resizer.size.y/2
	top_anchor.size.x = resizer.position.x+resizer.size.x
	
	note_bg_.size = resizer.position+resizer.size-Vector2(10,10)

func _on_color_pick_btn_pressed() -> void:
	color_picker_button.popup()
	color_choose = true

func _on_color_picker_button_color_changed(color: Color) -> void:
	self.change_colors(color)
	_color = color

func change_colors(color: Color):
	if note_content.get_child_count() > 0:
		note_content.change_color(color)

func _on_note_bar_mouse_exited() -> void:
	if color_choose:
		await color_picker_button.popup_closed
	#note_bar.hide()
	color_picker_button.hide()
	close.hide()
	note_bar.get_parent().color[3] = 0
	


func _on_note_bar_mouse_entered() -> void:
	#note_bar.show()
	color_picker_button.show()
	close.show()
	note_bar.get_parent().color[3] = 1


func _on_color_picker_button_mouse_entered() -> void:
	_on_note_bar_mouse_entered()


func _on_color_picker_button_mouse_exited() -> void:
	_on_note_bar_mouse_exited()


func _on_close_mouse_entered() -> void:
	_on_note_bar_mouse_entered()


func _on_close_mouse_exited() -> void:
	_on_note_bar_mouse_exited()


func _on_color_picker_button_pressed() -> void:
	color_choose = true


func _on_color_picker_button_popup_closed() -> void:
	color_choose = false
