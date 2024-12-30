# godot-dev-tabs
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

Currently available features:
	- Tab View

Currently in Progress
	- Editor which can load files into the editor and save them again, a recent file history is build in, and currently limited to 10 files, these are stored in the user directory of the game


Roadmap:
	Definitly:
		- Note taking
	Nice to have:
		- 
	Maybe, maybe not:
		- basic pixel art editor to scratch out some art quickly
