# godot-dev-tabs v1.0.0
This utility tool, is made to make development of games easier.
It allows to toggle of and on a mode to view the Game in the dev/game mode, in devmode, you can switch between tabs to navigate thgrough the tool.
currently I planned a note taking plane and a gdd(or other documents) view/editor, to support quick access without switching between apps

If you want to use this tool, just start with a fresh project and copy the folder dev_tabs and the settings script over, or just copy this project.
Depending on which mode you are in, in editor you can toggle the modes in the root node or ingame with f1(just note_mode), the game node will reparent to root/game_area
replace then the game node with your own game scene or use the game node to build up your game.
Make sure that you autoload the settings script!

The game area is outside the tabs, due to the cmaera not wokring with the canvas sadly, so it seems to be a mistake but it is intentional,
the extra control node is just to squish down the Game a bit, that it does not cover up the tabs.

Currently it just works for 2D Games

##############################

The editor lets you save and load textfiles,
the note taking view, will add a new note when you click the right mouse button,
	if you hit the save button(currently only one note file is possible, may extend it in the future), the note will be stored in the user folder of the game
you can toggle the autoload feature in both views seperately, in the editor it will be the last file edited

##############################

Currently available features:
	- Tab View
	- editor to load textfiles and and save them again, a recent file history is build in, and currently limited to 10 files, the history(not the actual files) are stored in the user directory of the game
	- Note taking

Currently in Progress
	

Roadmap:
	Definitly:
	Nice to have:
	Maybe, maybe not:
		- basic pixel art editor to scratch out some art quickly
