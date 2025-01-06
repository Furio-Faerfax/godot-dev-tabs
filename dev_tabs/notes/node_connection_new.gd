extends Node2D

class_name node_connection_new_
@onready var line: Line2D = $line
@onready var arrow: Node2D = $line/interact/arrow
@onready var arrow_1: Line2D = $line/interact/arrow/arrow_1
@onready var arrow_2: Line2D = $line/interact/arrow/arrow_2
@onready var naming: Node2D = $line/naming
@onready var name_text: TextEdit = $line/naming/name_text
@onready var text_node: Label = $line/interact/text
@onready var interact: ColorRect = $line/interact/interact

@onready var selected_timeout: Timer = $selected_timeout

var point_a = Vector2()
var point_b = Vector2(10,10)

@onready var grabber_a: ColorRect = $line/interact/grabber_a
@onready var grabber_b: ColorRect = $line/interact/grabber_b



@onready var interact_node: Node2D = $line/interact




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
 	
var anchor_1
var anchor_2

var input
var output

var is_valid = false
var start :Vector2

var arrow_1_target: Vector2
var arrow_2_target: Vector2

var drag_a := false
var drag_b := false


func _ready() -> void:
	#arrow_1_target = arrow_1.points[1] - arrow_1.points[0]
	#arrow_2_target = arrow_2.points[1] - arrow_2.points[0]
	#text = "lorem"
	#adjust_target()
	adjust_position()
	self.z_index = 100
	naming.z_index = 101
	Settings.connection_selection.connect(connection_selected)
	
	
	start = grabber_a.position
	target = grabber_b.position
	line.points[0] = start
	line.points[1] = target
	#adjust_position()
	
func _process(_delta: float) -> void:
	if text != text_ and text_ != "" and text_init:
		text = text_
		text_init = false
		
	
	if drag_a:
		line.points[0] = get_local_mouse_position()
		grabber_a.position = get_local_mouse_position()
		start = grabber_a.position
	if drag_b:
		line.points[1] = get_local_mouse_position()
		grabber_b.position = get_local_mouse_position()
		target = grabber_b.position
		adjust_position()
	#target = get_local_mouse_position()

	
	#line_3.points[1] = point_b
	#line_2.points[1] = point_b
	
	#line_3.points[0] = point_b-Vector2(5,5)


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

func adjust_target1():
	if output:
		start = output.get_position()+anchor_1.node_type.get_position()
	if input:
		target = (input.get_position()+anchor_2.node_type.get_position())
	
func adjust_position():
	#self.position = start
	if line:
		line.points[1] = target-self.position
	var distance_start_target: float = target.distance_to(start)
	var dir = target.direction_to(start)
	var dirgree = dir.x * dir.y
	if interact:
		interact.rotation_degrees = dirgree
		print(interact)
		if interact:
			interact.size.x = distance_start_target
		interact.get_node("../text").size.x = distance_start_target
		$line/interact/arrow.position.x = distance_start_target
		#naming.position = Vector2(start.x - start.distance_to(target) / 2, start.y - start.distance_to(target)/ 2)
		var angle = target.angle_to_point(start)
		interact.get_node("..").rotate(angle)
			
		#if arrow_1:
			#arrow_1.points[1] = target
			#arrow_1.points[0] = target-self.position
		#if arrow_2:
			#arrow_2.points[1] = target-self.position
			#arrow_2.points[0] = arrow_2.points[1] - arrow_2_target


func _on_grabber_a_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			if event.button_index == MOUSE_BUTTON_LEFT:
				drag_a = true
				#offset = note_template.position-field_bg.get_local_mouse_position()
			if not event.pressed:
				drag_a = false


func _on_grabber_b_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			if event.button_index == MOUSE_BUTTON_LEFT:
				drag_b = true
				#offset = note_template.position-field_bg.get_local_mouse_position()
			if not event.pressed:
				drag_b = false
