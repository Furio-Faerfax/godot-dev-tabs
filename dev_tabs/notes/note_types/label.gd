extends ColorRect
@onready var note: Node2D = $"../../.."

@onready var connector: Control = $"../../connector"
@onready var resizer: ColorRect = $"../../resizer"
@onready var note_bg: ColorRect = $"../../note_bg"
@onready var color_picker_button: ColorPickerButton = $"../note_bar/note_bar/ColorPickerButton"
@onready var note_bar: ColorRect = $"../note_bar"
@onready var title: Label = $"../note_bar/note_bar/title"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	note.note_type = "label"
	connector.queue_free()
	resizer.queue_free()
	color_picker_button.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func fill_data():
	pass


func update_data():
	title.text = "HELLO"
	note_bar.color[3] = 0
	note_bg.color = Color(0,0,0,0)
	self.color = Color(0,0,0,0)
	pass

func change_color(_color):
	pass
