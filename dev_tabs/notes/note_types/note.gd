extends ColorRect
@onready var note: Node2D = $"../../.."

@onready var text_edit: TextEdit = $TextEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	note.note_type = "note"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func fill_data():
	
	note.text = text_edit.text


func update_data():
	text_edit.text = note.text
