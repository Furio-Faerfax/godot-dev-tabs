extends Control

signal drop_button_pressed(type, action_content)

@onready var entries: VBoxContainer = $scroller/entries
@export var save_path := ""
@export var type := ""
@export var max_recent_files := 10

const DROP_DOWN_BUTTON = preload("res://dev_tabs/drop_down/drop_down_button.tscn")

var drop_list: Array = []
var file = dev_tab_file_handler.new()


func _ready() -> void:
	_gen_list()

func _gen_list():
	drop_list = file.loading(save_path)
	for entry in drop_list:
		entry.remove_at(entry.size()-1)
		entry.remove_at(entry.size()-1)
		if entry[0] != "" and entry.size() > 1:
			var inst = DROP_DOWN_BUTTON.instantiate()
			inst.text = entry[0]
			inst.file_path = entry[1]
			inst.type = type
			inst.drop_button_pressed.connect(drop_button_pressed_link)
			entries.add_child(inst)
			inst.owner = self

func _save_list():
	var text := ""
	for entry in drop_list:
		if entry.size() > 1:
			if entry.size() > 13:
				entry.remove_at(entry.size()-1)
				
			if entry.size() > 12:
				entry.remove_at(entry.size()-1)
			#print(entry)
			text += "\n"+str(entry[0])+"|"+str(entry[1])
			file.save(save_path, text)

func drop_button_pressed_link(_type, action_content):
	drop_button_pressed.emit(_type, action_content)

func add_new_to_list(new_entry):
	drop_list.push_front([new_entry[1], str(new_entry[0])+"."+str(new_entry[2])])
	for drops in drop_list.size()-1:
		if drop_list[drops][0] == "":
			drop_list.pop_at(drops)
	
	for i in drop_list.size()-1:
		if i == 0:
			continue
		if drop_list[i][0] == new_entry[1]:
			drop_list.pop_at(i)
			break
	
	if drop_list.size() > max_recent_files:
		entries.remove_child(entries.get_child(max_recent_files))
		drop_list.pop_back()
	
	new_file_saved()

func sort_up(_title, path):
	for entry in drop_list.size()-1:
		if drop_list[entry][0] == _title:
			var temp = drop_list[entry]
			drop_list.pop_at(entry)
			drop_list.push_front(temp)
			for ent in entries.get_children():
				if ent.file_path == path:
					entries.move_child(ent, 0)
					break
			break
	_save_list()

func new_file_saved():
	for entry in entries.get_children():
		entry.free()
	
	_save_list()
	_gen_list()
