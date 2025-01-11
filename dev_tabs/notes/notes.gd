extends Control
@onready var bg: ColorRect = $bg
@onready var notes: Control = $"."
@onready var editor: VBoxContainer = $"../editor"
@onready var field_bg: ColorRect = $field_bg
@onready var field: Control = $field_canvas/field
@onready var field_canvas: Control = $field_canvas
@onready var tab_splitter: HSplitContainer = $".."

const NOTE_TEMPLATE = preload("res://dev_tabs/notes/note_template.tscn")

var file = dev_tab_file_handler.new()
var field_drag = false
var offset = Vector2()

var note_ids := -1

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if field_drag:
		#offset = field.position - field_bg.position
		field.position = ( field_bg.get_local_mouse_position()+offset)

func _on_field_bg_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 3:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				field_drag = true
				offset = field.position-field_bg.get_local_mouse_position()
			if not event.pressed:
				field_drag = false
				
 
func _on_screen_resized():
	
	#field_bg.size.x = get_tree().root.get_viewport().get_size().x
	#field_bg.size.y = get_tree().root.get_viewport().get_size().y-13-10
	field_canvas.size.x = field_bg.size.x -25
	field_canvas.size.y = get_tree().root.get_viewport().get_size().y-field_canvas.position.y-45

func _on_new_note_pressed() -> void:
	note_ids += 1
	var inst = NOTE_TEMPLATE.instantiate()
	inst.field_bg = field_bg
	inst._node_id = note_ids
	field.add_child(inst)


func _on_save_notes_pressed() -> void:
	var data_string :String = ""
	var index := 0
	
	for each in field.get_child_count():
		if each == 0:
			continue
		data_string = str(data_string)+str(index)+";"+str(field.get_child(each).get_data())+"\n"
		index += 1
		
	for connection_inst in field.get_child(0).get_children():
		data_string = str(data_string)+str(index)+";"+str(connection_inst.get_data())+"\n"
		index += 1
		
	file.save(str(Settings.user_dir)+str(Settings.note_file), data_string)


func clear_field():
	for entry in field.get_children():
		if entry.name == "connections":
			var conecs = entry.get_children()
			for conec in conecs:
				conec.queue_free()
			continue
		entry.queue_free()
