![Plugin Logo](icon.svg)

# Godot Simple Menu

[![Godot Engine 4.3.1](https://img.shields.io/badge/Godot%20Engine-4.3-blue)](https://godotengine.org/)
[![MIT license](https://img.shields.io/badge/license-MIT-blue.svg)](https://lbesson.mit-license.org/)

---

Easy menu creation function：


```gdscript
func _ready():
	var menu : SimpleMenu = %Menu
	menu.init_menu({
		"File": [
			"Open", "Save", "Save As", "-",
			{"Export As...": [ "Export PNG", "Export JPG" ] }, "-",
			"Quit",
		],
		"Edit": [
			"Undo", "Redo", "-",
			"Copy", "Cut", "Clear",
		]
	})
```

A dictionary is equivalent to a menu, with a list of options and a string of options. Use the menu path for control.

![](addons/simplemenu/images/2024-04-07_081721.png)


Please refer to the example for details: **addons/simplemenu/example/**
