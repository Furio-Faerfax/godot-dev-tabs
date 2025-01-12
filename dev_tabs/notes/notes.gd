extends Control
@onready var bg: ColorRect = $bg
@onready var notes: Control = $"."
@onready var editor: VBoxContainer = $"../editor"
@onready var field_bg: ColorRect = $field_bg
@onready var field: Control = $field_canvas/field
@onready var field_canvas: Control = $field_canvas
@onready var tab_splitter: HSplitContainer = $".."
@onready var connections_field: Node2D = %connections_field
const NOTE = preload("res://dev_tabs/notes/note_types/note.tscn")
const NOTE_TEMPLATE = preload("res://dev_tabs/notes/note_template.tscn")
const NODE_CONNECTION = preload("res://dev_tabs/notes/node_connection.tscn")
const OUTPUT_ANCHOR = preload("res://dev_tabs/notes/output_anchor.tscn")
const INPUT_ANCHOR = preload("res://dev_tabs/notes/input_anchor.tscn")

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

#region signal_connections
func _on_field_bg_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == 3:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				field_drag = true
				offset = field.position-field_bg.get_local_mouse_position()
			if not event.pressed:
				field_drag = false
 
func _on_new_note_pressed() -> void:
	note_ids += 1
	var inst = NOTE.instantiate()
	#var inst = NOTE_TEMPLATE.instantiate()
	inst.field_bg = field_bg
	inst._node_id = note_ids
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
	for entry in field.get_children():
		if entry.name == "connections_field":
			var conecs = entry.get_children()
			for conec in conecs:
				conec.queue_free()
			continue
		entry.queue_free()

func _on_screen_resized():
	#field_bg.size.x = get_tree().root.get_viewport().get_size().x
	#field_bg.size.y = get_tree().root.get_viewport().get_size().y-13-10
	field_canvas.size.x = field_bg.size.x -25
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
func parsing_loaded_data(notes, connections) -> Array:
	for note in notes:
		#print(note)
		notes[note]["id"] = notes[note]["id"] as int
		notes[note]["position"] = Vector2(notes[note]["position"].split("_")[0] as float, notes[note]["position"].split("_")[1] as float)
		notes[note]["size"] = Vector2(notes[note]["size"].split("_")[0] as float, notes[note]["size"].split("_")[1] as float)
		notes[note]["color"] = Color(notes[note]["color"].split("_")[0] as float, notes[note]["color"].split("_")[1] as float, notes[note]["color"].split("_")[2] as float, notes[note]["color"].split("_")[3] as float)
		#print(notes[note])
	
	for connection in connections:
		connections[connection]["id_1"] = connections[connection]["id_1"] as int
		connections[connection]["id_2"] = connections[connection]["id_2"] as int
		connections[connection]["output_position"] = Vector2(connections[connection]["output_position"].split("_")[0] as float, connections[connection]["output_position"].split("_")[1] as float)
		connections[connection]["input_position"] = Vector2(connections[connection]["input_position"].split("_")[0] as float, connections[connection]["input_position"].split("_")[1] as float)
		#print(connections[connection])
	return [notes, connections]
#endregion

func spawn_notes_and_connections(dictionaries: Array):
	var notes = dictionaries[0]
	var connections = dictionaries[1]
	for note in notes:
		var skip = false
		var inst
		match notes[note]["type"]:
			"note":
				inst = NOTE.instantiate()
			_:
				skip = true
		if !skip:
			inst._node_id = notes[note]["id"]
			inst.note_type = notes[note]["type"]
			inst.position = notes[note]["position"]
			inst._size = notes[note]["size"]
			print(inst._size)
			inst.title = notes[note]["title"]
			inst.text = notes[note]["text"]
			inst._path = notes[note]["path"]
			inst._color = notes[note]["color"]
			inst.field_bg = field_bg
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
