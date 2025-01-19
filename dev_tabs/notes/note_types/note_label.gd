extends ColorRect

@onready var note: Node2D = $"../../.."
@onready var connector: Control = $"../../connector"
@onready var resizer: ColorRect = $"../../resizer"
@onready var note_bg: ColorRect = $"../../note_bg"
@onready var color_picker_button: ColorPickerButton = $"../note_bar/note_bar/ColorPickerButton"
@onready var note_bar: ColorRect = $"../note_bar"
@onready var title: Label = $"../note_bar/note_bar/title"
@onready var naming: Node2D = $naming
@onready var rename: Button = $"../note_bar/note_bar/rename"
@onready var close: Button = $"../note_bar/note_bar/close"
@onready var note_bar_color_rect: ColorRect = $"../note_bar"

const NOTE_TYPE = "label"

func _ready() -> void:
	note.note_type = NOTE_TYPE
	connector.hide()
	resizer.hide()
	color_picker_button.hide()
	
	close.hide()
	rename.hide()
	note_bar_color_rect.color[3] = 0
	
	if note.title == "":
		note._color = Color.WHITE
		naming.show()
		naming.get_node("name_text").grab_focus()


func fill_data():
	pass


func update_data():
	note_bar.color[3] = 0
	note_bg.color = Color(0,0,0,0)
	self.color = Color(0,0,0,0)

func change_color(_color):
	title.label_settings.font_color = _color


func _on_name_text_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("enter_rename"):
		title.text = naming.get_node("name_text").text
		note.title = title.text
		naming.hide()
