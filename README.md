Easy menu creation function：


```gdscript
func _ready():
	var menu : SimpleMenu = %Menu
	menu.init_menu({
		"File": [
			"Open", "Save", "Save As", "-",
			{"Export As": [ "Export PNG", "Export JPG" ] }, "-",
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


