extends Node

signal dev_mode_changed()

var dev_mode = true
var note_mode = true

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
