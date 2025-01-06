extends VBoxContainer

signal is_saved()
@onready var editor_open_dialog: FileDialog = %editor_open_dialog
@onready var editor_save_dialog: FileDialog = %editor_save_dialog
@onready var editor_unsaved_dialog: ConfirmationDialog = %editor_unsaved_dialog
@onready var drop_down: Control = $tools/drop_down
@onready var current_document: Label = $title_bar/current_document
@onready var autoload_first_recent: CheckButton = $tools/autoload_first_recent
@onready var text: TextEdit = $text

var current_title := "Untitled"
var document_changed := false
var unsaved_changes := false
var missing_file := false
var file = dev_tab_file_handler.new()
var new_doc = false


func _ready() -> void:
	current_document.text = current_title
	Settings.load_editor_first_recent.connect(autoload_first_recent_setting)

func _on_drop_down_drop_button_pressed(_type: Variant, action_content: Variant) -> void:
	if unsaved_changes:
		editor_unsaved_dialog.popup()
		await 1
		await editor_unsaved_dialog.visibility_changed
		await 1
		await is_saved
		unsaved_changes = false
		document_changed = false
	
	text.text = ""
	for line in action_content:
		text.text += line[0]+"\n"
	
	if action_content[0][2] == "file_deleted":
		file_deleted(action_content[0][3])
		missing_file = true
	else:
		missing_file = false
		for entry in drop_down.drop_list.size(): 
			#print(entry)
			if drop_down.drop_list[entry].size() > 1:
				if drop_down.drop_list[entry][1] == action_content[0][2]:
					current_title = drop_down.drop_list[entry][0]
					drop_down.sort_up(current_title, action_content[0][2])
			
		current_document.text = current_title

func file_deleted(path):
	for entry in drop_down.drop_list.size():  
		if drop_down.drop_list[entry][1] ==  path:
			current_title = drop_down.drop_list[entry][0]+" - file is missing, saving will save it at this path!"
			#drop_down.drop_list[entry][0] += str(" - this file is missing!")
			drop_down.get_node("scroller/entries").get_child(entry-1).text = drop_down.drop_list[entry][0]
			current_document.text = current_title

func _on_save_pressed() -> void:
	if current_title == "Untitled":
		editor_save_dialog.popup()
	else:
		current_document.text = str(current_title)
		unsaved_changes = false
		document_changed = false
		var title :String = current_title
		if missing_file:
			var _title = title.split("-")
			title = _title[0]
			title[title.length()-1] = ""
			
		for entry in drop_down.drop_list.size():
			if drop_down.drop_list[entry][0] == title:
				file.save(drop_down.drop_list[entry][1], text.text)
				is_saved.emit()
				break

func _on_text_text_changed() -> void:
	if !document_changed:
		document_changed = true
		current_document.text = str(current_title)+"*"
		unsaved_changes = true

func _on_file_dialog_file_selected(path: String) -> void:
	var splitted = path.split(".")
	if splitted[1] == "txt":
		var path_split = splitted[0]
		var path_split_folders = path_split.split("/")
		var file_name_split = path_split_folders[path_split_folders.size()-1]
		
		splitted[1] = file_name_split
		splitted.push_back("txt")
		#print(splitted)
		current_title = splitted[1]
		current_document.text = current_title
		drop_down.add_new_to_list(splitted)
		_on_drop_down_drop_button_pressed("file", file.loading(str(splitted[0])+"."+str(splitted[2])))

func _on_open_pressed() -> void:
	if unsaved_changes:
		editor_unsaved_dialog.popup()
		await 1
		await editor_unsaved_dialog.visibility_changed
	editor_open_dialog.popup()

func _on_new_pressed() -> void:
	new_doc = true
	if unsaved_changes:
		editor_unsaved_dialog.popup()
	else:
		current_document.text = "Untitled"
		current_title = "Untitled"
		text.text = ""

func _on_save_dialog_canceled() -> void:
	pass # Replace with function body.

func _on_save_dialog_file_selected(path: String) -> void:
	#print(path)
	var title_ = path.split("/")
	title_ = title_[title_.size()-1].split(".")
	current_title = title_[0]
	current_document.text = current_title
	if drop_down.drop_list[0][0] == "":
		drop_down.drop_list.pop_front()
	if drop_down.drop_list[drop_down.drop_list.size()-1][0] == "":
		drop_down.drop_list.pop_back()
	drop_down.drop_list.push_front([current_title, path])
	
	if drop_down.drop_list.size() > drop_down.max_recent_files:
		drop_down.drop_list.pop_back()
	#print(drop_down.drop_list)
	_on_save_pressed()
	
	drop_down.new_file_saved()


func _on_unsaved_changes_canceled() -> void:
	if new_doc:
		new_doc = false
		current_document.text = "Untitled"
		current_title = "Untitled"
		text.text = ""
	
	unsaved_changes = false
	document_changed = false
	is_saved.emit()


func _on_unsaved_changes_confirmed() -> void:
	_on_save_pressed()
	_on_unsaved_changes_canceled()


func _on_check_button_toggled(toggled_on: bool) -> void:
	Settings.change_setting("autoload_editor_first_recent", toggled_on)

func autoload_first_recent_setting(boo):
	if boo:
		autoload_first_recent.set_pressed_no_signal(true)
		for entry in drop_down.drop_list:
			if entry[0] == "":
				continue
			else:
				_on_drop_down_drop_button_pressed("", file.loading(entry[1]))
				break
