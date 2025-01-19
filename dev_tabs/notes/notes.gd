extends Control
@onready var bg: ColorRect = $bg
@onready var notes: Control = $"."
@onready var editor: VBoxContainer = $"../editor"
@onready var field_bg: ColorRect = $field_bg
@onready var field: Control = $field_canvas/field
@onready var field_canvas: Control = $field_canvas
@onready var tab_splitter: HSplitContainer = $".."
@onready var connections_field: Node2D = %connections_field

const NOTE_IMAGE = preload("res://dev_tabs/notes/note_types/note_image.tscn")
const NOTE = preload("res://dev_tabs/notes/note_types/note.tscn")
const NOTE_BORDER = preload("res://dev_tabs/notes/note_types/note_border.tscn")
const NOTE_TEMPLATE = preload("res://dev_tabs/notes/note_types/note_template.tscn")
const LABEL = preload("res://dev_tabs/notes/note_types/label.tscn")
@onready var autoload_notes: CheckButton = $tools/autoload_notes

const NODE_CONNECTION = preload("res://dev_tabs/notes/node_connection.tscn")
const OUTPUT_ANCHOR = preload("res://dev_tabs/notes/output_anchor.tscn")
const INPUT_ANCHOR = preload("res://dev_tabs/notes/input_anchor.tscn")
var note_type = "image"
var file = dev_tab_file_handler.new()
var field_drag = false
var offset = Vector2()
var note_ids := -1

func _ready() -> void:
	Settings.note_autoload.connect(_autoload_notes)
	tab_splitter.splitter_is_dragging_now.connect(_on_screen_resized)

func _process(_delta: float) -> void:
	if field_drag:
		#offset = field.position - field_bg.position
		field.position = ( field_bg.get_local_mouse_position()+offset)

#region signal_connections
func _on_field_bg_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 3:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				field_drag = true
				offset = field.position-field_bg.get_local_mouse_position()
			if not event.pressed:
				field_drag = false
	if event.is_action_released("mouse_right_dev_tabs"):
		_on_new_note_pressed()
 
func _on_new_note_pressed() -> void:
	note_ids += 1
	
	var inst
	match note_type:
		"note":
			inst = NOTE.instantiate()
		"border":
			inst = NOTE_BORDER.instantiate()
		"label":
			inst = LABEL.instantiate()
		"image":
			inst = NOTE_IMAGE.instantiate()
		_:
			inst = NOTE_TEMPLATE.instantiate()
			
	#var inst = NOTE_TEMPLATE.instantiate()
	inst.field_bg = field_bg
	inst._node_id = note_ids
	inst.position = field.get_local_mouse_position()
	field.add_child(inst)

func _on_clear_field_pressed() -> void:
	clear_field()

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
#endregion

func clear_field():
	note_ids = -1
	for entry in field.get_children():
		if entry.name == "connections_field":
			var conecs = entry.get_children()
			for conec in conecs:
				conec.queue_free()
			continue
		entry.queue_free()

func _on_screen_resized():
	#field_bg.size.x = get_tree().root.get_viewport().get_size().x-notes.position.x-20
	#field_bg.size.y = get_tree().root.get_viewport().get_size().y-13-10
	field_canvas.size.x = get_tree().root.get_viewport().get_size().x-notes.position.x-20
	print(field_bg.size)
	field_canvas.size.y = get_tree().root.get_viewport().get_size().y-field_canvas.position.y-45

#region Loading and Parsing the Note File
## Load the notes file and split it up into two sepearte dictionaies
func _on_load_notes_pressed() -> void:
	clear_field()
	var note_content = file.load_reloaded(str(Settings.user_dir)+str(Settings.note_file), ";")
	var notes_lines = []
	
	for line in note_content:
		if line.size() < 2:
			continue
			
		notes_lines.push_back(line[1].split("|"))
	
	var note_dictionary:Dictionary = {}
	var connection_dictionary:Dictionary = {}
	var index_notes := 0
	var index_connections := 0
	var is_connection := false
	for line in notes_lines:
		if line[0].split(":")[1] == "connection":
			is_connection = true
		else:
			is_connection = false
		
		var entr_dictionary :Dictionary ={}
		for entry in line:
			var splitted = entry.split(":")
			entr_dictionary[splitted[0]] = splitted[1]

		if is_connection:
			connection_dictionary[index_connections] = entr_dictionary
			index_connections += 1
		else:
			note_dictionary[index_notes] = entr_dictionary
			index_notes += 1

	var dictionaries = parsing_loaded_data(note_dictionary, connection_dictionary)
	spawn_notes_and_connections(dictionaries)
	
## Parsing the Dictionaries to the specified datatypes
func parsing_loaded_data(_notes, connections) -> Array:
	for note in _notes:
		#print(note)
		_notes[note]["id"] = _notes[note]["id"] as int
		_notes[note]["position"] = Vector2(_notes[note]["position"].split("_")[0] as float, _notes[note]["position"].split("_")[1] as float)
		_notes[note]["size"] = Vector2(_notes[note]["size"].split("_")[0] as float, _notes[note]["size"].split("_")[1] as float)
		_notes[note]["color"] = Color(_notes[note]["color"].split("_")[0] as float, _notes[note]["color"].split("_")[1] as float, _notes[note]["color"].split("_")[2] as float, _notes[note]["color"].split("_")[3] as float)
		#print(notes[note])
	
	for connection in connections:
		connections[connection]["id_1"] = connections[connection]["id_1"] as int
		connections[connection]["id_2"] = connections[connection]["id_2"] as int
		connections[connection]["output_position"] = Vector2(connections[connection]["output_position"].split("_")[0] as float, connections[connection]["output_position"].split("_")[1] as float)
		connections[connection]["input_position"] = Vector2(connections[connection]["input_position"].split("_")[0] as float, connections[connection]["input_position"].split("_")[1] as float)
		#print(connections[connection])
	return [_notes, connections]
#endregion

func spawn_notes_and_connections(dictionaries: Array):
	var _notes = dictionaries[0]
	var connections = dictionaries[1]
	for note in _notes:
		var skip = false
		var inst
		match _notes[note]["type"]:
			"note":
				inst = NOTE.instantiate()
			"border":
				inst = NOTE_BORDER.instantiate()
			"label":
				inst = LABEL.instantiate()
			"image":
				inst = NOTE_IMAGE.instantiate()
			_:
				skip = true
		if !skip:
			inst._node_id = _notes[note]["id"]
			inst.note_type = _notes[note]["type"]
			inst.position = _notes[note]["position"]
			inst._size = _notes[note]["size"]
			#print(inst._size)
			inst.title = _notes[note]["title"]
			inst.text = _notes[note]["text"]
			inst._path = _notes[note]["path"]
			inst._color = _notes[note]["color"]
			inst.field_bg = field_bg
			#inst.resizing()
			field.add_child(inst)
		
	for connection in connections:
		var inst = NODE_CONNECTION.instantiate()
		var note_1_id :int = connections[connection]["id_1"]
		var note_2_id :int = connections[connection]["id_2"]
		var output_pos :Vector2 = connections[connection]["output_position"]
		var input_pos :Vector2 = connections[connection]["input_position"]
		
		for each in field.get_child_count():
			if each == 0:
				continue
			var note = field.get_child(each)
			match note._node_id:
				note_1_id:
					var output = OUTPUT_ANCHOR.instantiate()
					print(note)
					note.anchor_collector.add_child(output)
					output.position = output_pos
					inst.note_1 = note
					inst.output = output
				note_2_id:
					var input = INPUT_ANCHOR.instantiate()
					note.anchor_collector.add_child(input)
					input.position = input_pos
					inst.note_2 = note
					inst.input = input
				
		
		inst.text = connections[connection]["text"]
		inst.connections_field = connections_field
		inst.note_1.connected_over.push_back(inst)
		inst.note_2.connected_over.push_back(inst)
		inst.is_on_load = true
		#inst.on_load_update_text()
		connections_field.add_child(inst)
		#
		#print(connections[connection])


func _on_autoload_first_recent_toggled(toggled_on: bool) -> void:
	Settings.change_setting("autoload_note", toggled_on)



func _autoload_notes(boo):
	if boo:
		autoload_notes.set_pressed_no_signal(true)
		_on_load_notes_pressed()
