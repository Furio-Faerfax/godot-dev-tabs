extends Node2D

class_name node_connection
@onready var line: Line2D = $line
@onready var arrow: Node2D = $line/interact/arrow
@onready var arrow_1: Line2D = $line/interact/arrow/arrow_1
@onready var arrow_2: Line2D = $line/interact/arrow/arrow_2
@onready var naming: Node2D = $line/naming
@onready var name_text: TextEdit = $line/naming/name_text
@onready var text_node: Label = $line/interact/text
@onready var interact: ColorRect = $line/interact/interact

@onready var selected_timeout: Timer = $selected_timeout

var point_a := Vector2()
var point_b := Vector2(10,10)

var is_connecting := false






var node_base: Node2D
var text_init = true
var text_: String = ""
var text: String:
	set(val):
		text = val
		text_node.text = val
		
var target :Vector2 :
	set(vec):
		target = vec
		if line:
			#adjust_position()
			pass
 	
var note_1
var note_2

var input
var output

var start :Vector2

var arrow_1_target: Vector2
var arrow_2_target: Vector2
@onready var connections_field: Node2D = %connections_field



func _ready() -> void:
	adjust_target()
	self.z_index = 100
	naming.z_index = 101
	Settings.connection_selection.connect(connection_selected)

func _process(_delta: float) -> void:
	if text != text_ and text_ != "" and text_init:
		text = text_
		text_init = false
	
	if is_connecting:
		point_a = output.position
		point_b = input.position
		line.points[0] = point_a
		line.points[1] = point_b
	else:
		self.reparent(connections_field)

func _on_interact_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.

func _on_name_text_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.
	
func connection_selected():
	if Settings.focused_node == self:
		_change_color(Color.GREEN)
		selected_timeout.start(5)
	else:
		_change_color(Color.WHITE)

func _change_color(val):
	line.default_color = val
	arrow_1.default_color = val
	arrow_2.default_color = val

func adjust_target():
	if note_1 and note_2:
		target = input.position+note_2.get_global_transform()[2]-(note_1.get_global_transform()[2])

	line.points[1] = target
