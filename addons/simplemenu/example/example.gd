@tool
extends Control

const ICONS = preload("res://addons/simplemenu/example/icons.tres")

func _ready():
	var simple_menu = %SimpleMenu
	simple_menu.init_menu({
		"File": [
			"Open", "Save", "Save As", "-",
			"Auto Save", {"Export As...": [ "Export PNG", "Export JPG" ] }, "-",
			"Quit",
		],
		"Edit": [
			"Undo", "Redo", "-",
			"Copy", "Paste", "Cut", "Clear", "-",
		]
	})
	
	simple_menu.init_shortcut({
		"/File/Open": "Ctrl+O",
		"/File/Save": "Ctrl+S",
		"/File/Save As": "Ctrl+Shift+S",
		"/Edit/Undo": "Ctrl+Z",
		"/Edit/Redo": "Ctrl+Shift+Z",
		"/Edit/Copy": "Ctrl+C",
		"/Edit/Paste": "Ctrl+V",
		"/Edit/Cut": "Ctrl+X",
	})
	
	simple_menu.init_icon({
		"/File/Open": ICONS.get_icon("File", "EditorIcons"),
		"/File/Save As": ICONS.get_icon("Save", "EditorIcons"),
		"/Edit/Undo": ICONS.get_icon("UndoRedo", "EditorIcons"),
		"/Edit/Copy": ICONS.get_icon("ActionCopy", "EditorIcons"),
		"/Edit/Cut": ICONS.get_icon("ActionCut", "EditorIcons"),
		"/Edit/Paste": ICONS.get_icon("ActionPaste", "EditorIcons"),
		"/Edit/Clear": ICONS.get_icon("Clear", "EditorIcons"),
	})
	
	simple_menu.set_menu_as_checkable("/File/Auto Save", true)
	simple_menu.set_menu_checked("/File/Auto Save", true)


func _on_simple_menu_menu_pressed(idx, menu_path):
	# Implement menu functions 
	print("Clicked: ", menu_path)
