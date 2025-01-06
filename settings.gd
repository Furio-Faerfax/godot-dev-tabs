extends Node

signal dev_mode_changed()

signal load_editor_first_recent(boo)

signal connection_selection()


signal connection_area_entered(id_connection: int, area: String)
signal connection_area_exited(id_connection: int, area: String)

@onready var root = $"."

var dev_mode = true
var note_mode = true

var settings :Dictionary = {"autoload_editor_first_recent": false}

var _file = dev_tab_file_handler.new()
var user_dir = "user://"
var setting_file = "settings.txt"

## Adding a input key to the project via code, to ensure that any project includes this feature naturally, disabling later when development is done!
func _ready():
	InputMap.add_action("switch_note_mode")
	var ev = InputEventKey.new()
	ev.keycode = KEY_F1
	InputMap.action_add_event("switch_note_mode", ev)
	
	
	#_open_user_directory()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
	if Input.is_action_just_released("switch_note_mode"):
		dev_mode = !dev_mode
		dev_mode_changed.emit()


func _open_user_directory():
	OS.shell_open(OS.get_user_data_dir())

func change_setting(setting, boo):
	## When a setting is changed, the dictionary gets updated
	match setting:
		"autoload_editor_first_recent":
			settings["autoload_editor_first_recent"] = boo
			print(boo)
		_:
			pass
	
	## then, the settings file will be resaved
	var settings_str = ""
	for settings_count in settings.size():
		print(settings_count)
		var key = settings.keys()[settings_count]
		var value = settings[key]
		settings_str += str(key)+"|"+str(value)+"\n"
		#print(settings_str)
	_file.save(str(user_dir)+str(setting_file), settings_str)
	#print(settings)

func load_settings():
	var arr = _file.load_reloaded(str(user_dir)+str(setting_file), "|")
	for line in arr:
		#print(line)
		match line[0]:
			"autoload_editor_first_recent":
				var boo = true if line[1] == "true" else false
				settings["autoload_editor_first_recent"] = boo
				load_editor_first_recent.emit(boo)
	#print(settings)
