extends Node
@onready var notes: Control = $"../.."

@export var note_types:Array
@onready var entries: VBoxContainer = $entries
const DROP_DOWN_BUTTON = preload("res://dev_tabs/drop_down/drop_down_button.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for entry in note_types.size():
		var inst = DROP_DOWN_BUTTON.instantiate()
		var tmp:Node2D = note_types[entry].instantiate()
		add_child(tmp)
		inst.name = tmp.note_content.NOTE_TYPE
		inst.text = tmp.note_content.NOTE_TYPE
		inst.type = tmp.note_content.NOTE_TYPE
		entries.add_child(inst)
		inst.drop_button_pressed.connect(_on_pressed)
		inst.file = null
		tmp.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed(type, cont):
	notes.note_type = type
