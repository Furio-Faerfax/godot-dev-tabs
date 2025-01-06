extends TabContainer
## This script switch between normal game mode and note tab system while developing

@onready var root: Control = $"../.."
@onready var tabs: TabContainer = $"."
@onready var game_tab: Control = $game
@onready var game_area: Node2D = $"../../game_area"

@onready var game: Node2D = $"../../game"

var init := true


func _ready() -> void:
	Settings.dev_mode_changed.connect(switch_tabs)

func _process(_delta: float) -> void:
	if init:
		init = false
		switch_tabs()

func switch_tabs():
	if Settings.dev_mode and Settings.note_mode:
		tabs.show()
		game.reparent(game_area)
	else:
		tabs.hide()
		game.reparent(root)
		game.show()

func _on_tab_changed(tab: int) -> void:
	if tab != 0:
		if game:
			game.hide()
			game.process_mode = Node.PROCESS_MODE_DISABLED
			root.hud.hide()
	else:
		game.show()
		game.process_mode = Node.PROCESS_MODE_INHERIT
		root.hud.show()
