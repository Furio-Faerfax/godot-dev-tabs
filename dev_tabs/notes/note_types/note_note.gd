extends ColorRect

@onready var note: Node2D = $"../../.."
@onready var note_bg_: ColorRect = $"../../note_bg"
@onready var note_content: ColorRect = $"."
@onready var text_edit: TextEdit = $TextEdit

const NOTE_TYPE = "note"


func _ready() -> void:
	note.note_type = NOTE_TYPE

func fill_data():
	note.text = text_edit.text

func update_data():
	text_edit.text = note.text

func change_color(_color):
	note_content.color = color
	note_bg_.color = color
