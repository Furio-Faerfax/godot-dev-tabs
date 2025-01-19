extends ColorRect
@onready var note: Node2D = $"../../.."

@onready var left: ColorRect = $"../../connector/anchors/left"
@onready var top: ColorRect = $"../../connector/anchors/top"
@onready var down: ColorRect = $"../../connector/anchors/down"
@onready var right: ColorRect = $"../../connector/anchors/right"
@onready var v_box_container: VBoxContainer = $".."

@onready var note_bg: ColorRect = $"../../note_bg"
@onready var note_content: ColorRect = $"."
@onready var note_bar_color_rect: ColorRect = $"../note_bar"
@onready var color_picker_button: ColorPickerButton = $"../note_bar/note_bar/ColorPickerButton"
@onready var rename: Button = $"../note_bar/note_bar/rename"
@onready var close: Button = $"../note_bar/note_bar/close"


const NOTE_TYPE = "border"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	note.note_type = NOTE_TYPE
	color_picker_button.hide()
	
	close.hide()
	rename.hide()
	note_bar_color_rect.color[3] = 0
	#v_box_container.mouse_filter = Control.MOUSE_FILTER_PASS
	#note_bg.mouse_filter = Control.MOUSE_FILTER_PASS
	#note_content.mouse_filter = Control.MOUSE_FILTER_PASS
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func fill_data():
	#note.text = text_edit.text
	pass


func update_data():
	pass
	
func change_color(_color):
	note_content.color = color
	#note_bg_.color = color
	note_bg.color =  Color(0,0,0,0)
	note_content.color = Color(0,0,0,0)
	
	left.color = _color
	right.color = _color
	top.color = _color
	down.color = _color
	


func _on_note_bar_mouse_entered() -> void:
	pass # Replace with function body.
