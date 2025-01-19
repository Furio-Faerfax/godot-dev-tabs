extends Control

@export var dev_mode_toggle = true
@export var note_mode_toggle = true
@export var hud: CanvasLayer


func _ready() -> void:
	Settings.dev_mode = dev_mode_toggle
	Settings.note_mode = note_mode_toggle
	Settings.load_settings()
