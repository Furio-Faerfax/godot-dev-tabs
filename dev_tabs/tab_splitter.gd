extends HSplitContainer
## This script changes the split offset, when the drag bar isnt moved, the split will remain in the window center, if its moved its not recentered when the size of the window is changing
## resetting this behavior can be done, clicking the right mosusebutton when dragging, even if the cursor will drag it again while release the left button, it is resetted and will reposition when window size is changing

signal splitter_is_dragging_now()

@onready var notes: Control = $notes
@onready var tab_splitter: HSplitContainer = $"."
@onready var notes_tab: TabBar = $".."

var auto_resize := true
var dragging := true
var right_clicked := false


func _ready() -> void:
	get_tree().root.size_changed.connect(_on_viewport_size_changed)
	split_offset = DisplayServer.window_get_size().x/2.0 as int
	_on_viewport_size_changed()


func _on_viewport_size_changed():
	#tab_splitter.set_deferred("size", Vector2(get_tree().root.get_viewport().get_size().x, get_tree().root.get_viewport().get_size().y-notes_tab.position.y-2))
	tab_splitter.set_anchor_and_offset(SIDE_RIGHT, get_tree().root.get_viewport().get_size().x, 0)
	tab_splitter.set_anchor_and_offset(SIDE_BOTTOM, get_tree().root.get_viewport().get_size().y-notes_tab.position.y-2, 0)
	#tab_splitter.size.x = get_tree().root.get_viewport().get_size().x
	#tab_splitter.size.y = get_tree().root.get_viewport().get_size().y-notes_tab.position.y-2
	notes._on_screen_resized()
	
	if auto_resize:
		var window_size = get_tree().root.get_viewport().get_size()
		split_offset = window_size.x/2


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if  event.is_released():
			dragging = false
			right_clicked = false
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() and dragging:
		auto_resize = true
		right_clicked = true
		_on_viewport_size_changed()


func _on_dragged(_offset: int) -> void:
	splitter_is_dragging_now.emit()
	if auto_resize and not right_clicked:
		auto_resize = false
	if not dragging: 
		dragging = true
