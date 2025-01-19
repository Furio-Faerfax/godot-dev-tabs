extends ColorRect

@onready var note: Node2D = $"../../.."
@onready var note_bg_: ColorRect = $"../../note_bg"
@onready var note_content: ColorRect = $"."
@onready var open: Button = $open
@onready var _image: TextureRect = $image
@onready var note_image_open_dialog: FileDialog = $note_image_open_dialog

const NOTE_TYPE = "image"

func _ready() -> void:
	note.note_type = NOTE_TYPE
	note_image_open_dialog.file_selected.connect(_on_image_selected)


func fill_data():
	pass


func update_data():
	if note._path != "":
		load_image(note._path)


func change_color(_color):
	note_content.color = color
	note_bg_.color = color


func _on_open_pressed() -> void:
	note_image_open_dialog.popup()

func _on_image_selected(path):
	var split = path.split(".")
	split = split[split.size()-1]
	if split == "png" or split == "jpeg" or split == "jpg" or split == "svg":
		load_image(path)


func _on_image_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_right_dev_tabs"):
		#resize = true
		pass
	if event.is_action_released("mouse_right_dev_tabs"):
		_on_open_pressed()


func load_image(path):
	note._path = path
	var image = Image.load_from_file(path)
	_image.texture = ImageTexture.create_from_image(image)
	open.hide()
