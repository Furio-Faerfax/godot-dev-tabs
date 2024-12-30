extends Button

class_name drop_down_button

signal drop_button_pressed(type, action_content)

var file = dev_tab_file_handler.new()
var file_path := ""
var type := ""


func _ready() -> void:
	pressed.connect(open)

func open():
	drop_button_pressed.emit(type, file.loading(file_path))
