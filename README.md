Easy menu creation function：


```gdscript
func _ready():
	SimpleMenuObject.init_menu({
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

![](addons/simplemenu/images/2024-04-07_081721.png)


Please refer to the example for details: **addons/simplemenu/example/**
