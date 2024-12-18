extends Control
@export var dev_mode_toggle = true
@export var note_mode_toggle = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Settings.dev_mode = dev_mode_toggle
	Settings.note_mode = note_mode_toggle


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
