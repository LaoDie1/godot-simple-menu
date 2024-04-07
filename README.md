轻松创建菜单功能，只需

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

即可快速创建菜单功能，详见 res://addons/simplemenu/example/ 中的实例
