extends TabContainer
## This script switch between normal game mode and note tab system while developing

@onready var root: Control = $".."
@onready var tabs: TabContainer = $"."
@onready var game_tab: TabBar = $game
@onready var game: Node2D = $"../game"

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
		game.reparent(game_tab)
	else:
		game.reparent(root)
		tabs.hide()
