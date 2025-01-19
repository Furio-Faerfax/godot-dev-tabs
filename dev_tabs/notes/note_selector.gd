extends Node

@onready var notes: Control = $"../.."
@onready var entries: VBoxContainer = $entries

@export var note_types:Array

const DROP_DOWN_BUTTON = preload("res://dev_tabs/drop_down/drop_down_button.tscn")

## This generates the Buttons for any Note type  for the scrollcontainer to select
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


func _on_pressed(type, _content):
	notes.note_type = type
