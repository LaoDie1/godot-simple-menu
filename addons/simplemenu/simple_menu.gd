#============================================================
#    simple Menu
#============================================================
# - author: zhangxuetu
# - datetime: 2025-6-23 04:03:10
# - version: 4.4.1
#============================================================
## 简单菜单。提供一个简单快速的方式创建菜单节点和功能
##
##通过调用 [method init_menu] 方法初始化菜单项，[method init_shortcut] 初始化快捷键。[br]
## 
##添加的菜单数据中 [Dictionary] 类型的数据创建菜单子节点，[Array] 添加菜单项
##[codeblock]
##$SimpleMenu.init_menu({
##    "File": [
##        "Open", "Save", 
##        {"Export": ["Text", "JSON", "CSV"]},  # 2级子菜单
##        "-", 
##        "Quit"
##    ], 
##    "Edit": ["Redo", "Undo"],
##})
##[/codeblock]
##添加快捷键
##[codeblock]
##$SimpleMenu.init_shortcut({
##    "/File/Open": "ctrl+o",
##    "/File/Save": "ctrl+s",
##    "/File/Quit": "ctrl+q",
##    "/Edit/Undo": "ctrl+z",
##    "/Edit/Redo": "ctrl+shift+z",
##})
##[/codeblock]
##连接菜单信号执行菜单功能
##[codeblock]
##$SimpleMenu.menu_pressed.connect(
##    func(idx, menu_path):
##        match menu_path:
##            "/File/Open":
##                pass
##            "/File/Save":
##                pass
##            "/File/Quit":
##                Engine.get_main_loop().quit() # 退出程序
##            "/Edit/Redo":
##                pass
##            "/Edit/Undo":
##                pass
##            _:
##                printerr("没有实现 %s 菜单的功能" % menu_path)
##                push_error("没有实现 %s 菜单的功能" % menu_path)
##)
##[/codeblock]
@tool
class_name SimpleMenu
extends MenuBar


## 菜单被点击
##[br]
##[br][kbd]idx[/kbd] 菜单的索引值
##[br][kbd]menu_path[/kbd] 菜单路径
signal menu_pressed(idx: int, menu_path: StringName)
## 复选框状态发生切换
signal menu_check_toggled(idx: int, menu_path: StringName, status: bool)


# 自动增长的菜单 idx。用以下面添加菜单项时记录添加的菜单的 idx
var _auto_increment_menu_idx := -1
# 菜单路径对应 PopupMenu
var _menu_path_to_popup_menu_map := {}
# 菜单的 idx 对应的菜单路径
var _idx_to_menu_path_map := {}
# 菜单路径对应的菜单 idx
var _menu_path_to_idx_map := {}
# 子节点路径
var _child_menu_path_idx_list := {}


#=====================================================
#   Set/Get
#=====================================================
## 获取弹窗菜单
##[br]
##[br][kbd]menu_path[/kbd]  这个菜单路径的父弹窗菜单节点
func get_menu(menu_path: StringName) -> PopupMenu:
	return _menu_path_to_popup_menu_map.get(menu_path) as PopupMenu


## 添加快捷键
##[br]
##[br][kbd]menu_path[/kbd]  菜单路径
##[br][kbd]data[/kbd]  快捷键数据，示例数据：[kbd]ctrl + shift + C[/kbd] 快捷键
##[codeblock]
##{
##    "ctrl": true,
##    "shift": true,
##    "keycode": KEY_C,
##}
##[/codeblock]
func set_menu_shortcut(menu_path: StringName, data):
	if data is String:
		data = parse_shortcut(data)
	var shortcut = Shortcut.new()
	var input = InputEventKey.new()
	shortcut.events.append(input)
	input.keycode = data.get("keycode", 0)
	input.ctrl_pressed = data.get("ctrl", false)
	input.alt_pressed = data.get("alt", false)
	input.shift_pressed = data.get("shift", false)
	
	var popup_menu : PopupMenu = get_menu(menu_path)
	if popup_menu:
		var menu_name : String = menu_path.get_file()
		for i in popup_menu.item_count:
			if popup_menu.get_item_text(i) == menu_name:
				popup_menu.set_item_shortcut(i, shortcut)
				break


func _execute_menu_by_path(menu_path: StringName, method_name: String, params: Array = []):
	var menu = get_menu(menu_path)
	var idx = get_menu_idx(menu_path)
	if menu and idx > 0:
		return menu.callv(method_name, params)
	return null


## 设置菜单的可用性
func set_item_disabled(menu_path: StringName, value: bool):
	var menu = get_menu(menu_path)
	var idx = get_menu_idx(menu_path)
	if menu and idx > -1:
		menu.set_item_disabled(idx, value)


## 设置菜单复选框启用状态
func set_menu_as_checkable(menu_path: StringName, value: bool):
	var menu = get_menu(menu_path)
	var idx = get_menu_idx(menu_path)
	if menu and idx > 0:
		menu.set_item_as_checkable(idx, value)

## 菜单复选框是否是启用的
func is_menu_as_checkable(menu_path: StringName) -> bool:
	var menu = get_menu(menu_path)
	var idx = get_menu_idx(menu_path)
	if menu and idx > 0:
		return menu.is_item_checkable(idx)
	return false

## 设置菜单项的图标
func set_icon(menu_path: StringName, icon: Texture2D):
	var popup_menu = get_menu(menu_path)
	var id = _menu_path_to_idx_map.get(menu_path, -1)
	if popup_menu and id > -1:
		var menu_name : String = menu_path.get_file()
		for i in popup_menu.item_count:
			if popup_menu.get_item_text(i) == menu_name:
				popup_menu.set_item_icon(i, icon)
				break

## 设置菜单为勾选状态
func set_menu_checked(menu_path: StringName, value: bool):
	var menu = get_menu(menu_path)
	var idx = get_menu_idx(menu_path)
	if menu and idx > -1:
		menu.set_item_as_checkable(idx, true)
		if menu.is_item_checked(idx) != value:
			menu.set_item_checked(idx, value)
			self.menu_check_toggled.emit(idx, menu_path, value)
	else:
		printerr("没有这个菜单：", menu_path)

## 获取这个菜单的勾选状态
func get_menu_checked(menu_path: StringName) -> bool:
	var menu = get_menu(menu_path)
	var idx = get_menu_idx(menu_path)
	if menu and idx > 0:
		return menu.is_item_checked(idx)
	return false

## 切换菜单的勾选状态
func toggle_menu_checked(menu_path: StringName) -> bool:
	var id = get_menu_idx(menu_path)
	var status = _execute_menu_by_path(menu_path, "is_item_checked", [id])
	set_menu_checked(menu_path, not status)
	return not status

## 获取这个菜单的索引，如果不存在这个菜单，则返回 [kbd]-1[/kbd]
func get_menu_idx(menu_path: StringName) -> int:
	var id = _menu_path_to_idx_map.get(menu_path, -1)
	var menu = get_menu(menu_path)
	if menu == null:
		var parent_path = get_parent_menu_path(menu_path)
		menu = get_menu(parent_path)
	return menu.get_item_index(id)


## 获取这个索引的菜单路径
func get_menu_path(menu_path: StringName) -> StringName:
	var idx = get_menu_idx(menu_path)
	return _idx_to_menu_path_map.get(idx, "")


## 是否有这个菜单路径
func has_menu_path(menu_path: StringName) -> bool:
	return _menu_path_to_popup_menu_map.has(menu_path)


## 获取父菜单路径
func get_parent_menu_path(menu_path: StringName) -> StringName:
	var idx : int = _menu_path_to_idx_map.get(menu_path, -1)
	if idx == -1:
		return ""
	for parent_path in _child_menu_path_idx_list:
		var list = _child_menu_path_idx_list[parent_path] as Array
		if list.has(idx):
			return parent_path
	return ""

func add_menu_by_path(menu_path: String):
	menu_path = menu_path.trim_prefix("/")
	var items = menu_path.split("/")
	var p : String = "/"
	for i in items.size():
		add_menu(items[i], p)
		p = p.path_join(items[i])


#=====================================================
#   自定义方法
#=====================================================
## 初始化菜单。示例：
## [codeblock]
## init_menu({
##    "File": [
##        "Open", "Save", "Save As", "-",
##        {"Export As": [ "Export PNG", "Export JPG" ] }, "-",
##        "Quit",
##    ],
##    "item": {
##        "letter": ["a", "b", "c"],
##        "number": [ "1", "2"],
##    },
## })
## [/codeblock]
func init_menu(data: Dictionary):
	add_menu(data, "/")


## 初始化快捷键，需要添加对应菜单。示例：
##[codeblock]
##{
##    "/File/Open": "ctrl+o",
##    "/File/Save": "Ctrl+S",
##    "/File/Export/JSON": "ctrl+shift+e, # 或者{"keycode": KEY_E, "shift": true, "ctrl": true}
##}
##[/codeblock]
func init_shortcut(data_list: Dictionary):
	var data
	for menu_path in data_list:
		data = data_list[menu_path]
		if data is String:
			data = parse_shortcut(data)
		set_menu_shortcut(menu_path, data)


## 初始化这些项的图标。示例：
##[codeblock]
##{
##    "/File/Open": Texture2D,
##    "/File/Save": Texture2D,
##    "/Edit/Copy": Texture2D,
##}
##[/codeblock]
func init_icon(data: Dictionary):
	for menu_path in data:
		set_icon( menu_path, data[menu_path] )


## 添加菜单项
##[br]
##[br][kbd]menu_data[/kbd]  这个菜单项包含的数据
##[br][kbd]parent_menu_path[/kbd]  父级菜单路径
func add_menu(menu_data, parent_menu_path: StringName):
	# 不是根路径时
	if parent_menu_path != "/":
		_auto_increment_menu_idx += 1
		var parent_popup_menu : PopupMenu = get_menu(parent_menu_path)
		# Dictionary
		if menu_data is Dictionary:
			for menu_name in menu_data:
				add_menu( menu_data[menu_name], parent_menu_path.path_join(menu_name))
		
		# Array
		elif menu_data is Array:
			for data in menu_data:
				add_menu(data, parent_menu_path)
		
		# String
		elif menu_data is String or menu_data is StringName:
			# 添加菜单
			if not _menu_path_to_popup_menu_map.has(parent_menu_path):
				_create_menu(parent_menu_path, null)
			parent_popup_menu = get_menu(parent_menu_path)
			# 不是 Array 和 Dictionary 类型时，只能是 String 类型了
			var menu_name := StringName(menu_data)
			if not menu_name.begins_with("-"):
				var menu_path := "%s/%s" % [parent_menu_path, menu_name] 
				# 添加菜单项
				parent_popup_menu.add_item(menu_name, _auto_increment_menu_idx)
				_idx_to_menu_path_map[_auto_increment_menu_idx] = menu_path
				_menu_path_to_idx_map[menu_path] = _auto_increment_menu_idx
				_menu_path_to_popup_menu_map[menu_path] = parent_popup_menu
				if not _child_menu_path_idx_list.has(parent_menu_path):
					_child_menu_path_idx_list[parent_menu_path] = []
				_child_menu_path_idx_list[parent_menu_path].append(_auto_increment_menu_idx)
				
			else:
				parent_popup_menu.add_separator()
		
		else:
			assert(false, "错误的数据类型：" + str(typeof(menu_data)) )
	
	else:
		# 根菜单按钮
		if menu_data is Dictionary:
			for menu_name in menu_data:
				# 添加菜单按钮
				var menu := PopupMenu.new()
				menu.name = menu_name
				add_child(menu)
				var menu_path : String = parent_menu_path.path_join(menu_name) 
				_register_popup_menu(menu_path, menu)
				# 添加这个按钮菜单的子菜单
				add_menu(menu_data[menu_name], menu_path)
		
		elif menu_data is Array:
			for menu_name in menu_data:
				add_menu(menu_name, "/")
		
		elif menu_data is String:
			var menu_path : String = parent_menu_path.path_join(menu_data) 
			menu_path = valid_menu_path(menu_path)
			if not _menu_path_to_popup_menu_map.has(menu_path):
				var menu := PopupMenu.new()
				menu.name = menu_data
				add_child(menu)
				_register_popup_menu(menu_path, menu)


func set_menu_disabled_by_path(menu_path:String, disable: bool):
	var idx : int = get_menu_idx(menu_path)
	if idx > -1:
		var menu = get_menu(menu_path)
		menu.set_item_disabled(idx, disable)


## 移除菜单
func remove_menu(menu_path: StringName) -> bool:
	if has_menu_path(menu_path):
		# 移除子菜单及其数据
		var child_menu_idx_list = _child_menu_path_idx_list.get(menu_path, [])
		for child_menu_idx in child_menu_idx_list:
			var child_menu_path = get_menu_idx(child_menu_idx)
			if has_menu_path(child_menu_path):
				remove_menu(child_menu_path)
		
		# 移除自身数据
		var idx = get_menu_idx(menu_path)
		
		# 移除菜单节点
		var menu = get_menu(menu_path) as PopupMenu
		if menu != null:
			menu.queue_free()
		else:
			var parent_menu_path = get_parent_menu_path(menu_path)
			var parent_menu = get_menu(parent_menu_path)
			parent_menu.remove_item(idx)
		
		_menu_path_to_popup_menu_map.erase(menu_path)
		_menu_path_to_idx_map.erase(menu_path)
		_idx_to_menu_path_map.erase(idx)
		return true
	return false


## 清空菜单
func clear_menu(menu_path: StringName) -> bool:
	if has_menu_path(menu_path):
		var menu = get_menu(menu_path)
		if menu != null:
			menu.clear()
			return true
	return false


# 创建菜单
#[br]
#[br][kbd]menu_path[/kbd]  菜单路径
#[br][kbd]parent_menu[/kbd]  父级菜单
func _create_menu(menu_path: StringName, parent_menu: PopupMenu):
	# 切分菜单名
	var parent_menu_names := menu_path.split("/")
	# 因为切分后 0 索引都是空字符串，所以移除
	parent_menu_names.remove_at(0)
	
	# 逐个添加菜单
	parent_menu = get_menu("/" + "/".join(parent_menu_names.slice(0, 1)))
	for i in parent_menu_names.size():
		var sub_menu_path = "/" + "/".join(parent_menu_names.slice(0, i + 1))
		# 没有这个菜单则添加
		if not _menu_path_to_popup_menu_map.has(sub_menu_path):
			var menu_name : String = parent_menu_names[i]
			var menu_popup : PopupMenu = _create_popup_menu(sub_menu_path)
			_menu_path_to_popup_menu_map[sub_menu_path] = menu_popup
			parent_menu.add_child(menu_popup)
			parent_menu.add_submenu_node_item( menu_name, menu_popup )
		# 开始记录这个菜单，用以这个菜单的下一级别的菜单
		parent_menu = get_menu(sub_menu_path)


## 解析快捷键字符串。将 [code]Ctrl+S[/code] 转为 [code]{"ctrl": true, "keycode": KEY_S}[/code]
static func parse_shortcut(shortcut_text: String) -> Dictionary:
	const CONTROL_KEY = ["ctrl", "shift", "alt"]
	var list = shortcut_text.split("+")
	var keymap : Dictionary = {
		"keycode": KEY_NONE,
		"ctrl": false,
		"shift": false,
		"alt": false,
	}
	for key in list:
		key = str(key).strip_edges().to_lower()
		if CONTROL_KEY.has(key):
			keymap[key] = true
		else:
			keymap["keycode"] = OS.find_keycode_from_string(key)
	return keymap



#=====================================================
#   连接信号
#=====================================================
# 创建这个路径的菜单
func _create_popup_menu(path: StringName) -> PopupMenu:
	var menu_popup = PopupMenu.new()
	menu_popup.name = path.get_file()
	_register_popup_menu(path, menu_popup)
	return menu_popup


func valid_menu_path(menu_path: String) -> String:
	if not menu_path.begins_with("/"):
		menu_path = "/" + menu_path
	if menu_path.ends_with("/"):
		menu_path = menu_path.trim_suffix("/")
	return menu_path

# 设置菜单属性
func _register_popup_menu(menu_path: StringName, menu_popup: PopupMenu):
	menu_path = valid_menu_path(menu_path)
	self._menu_path_to_popup_menu_map[menu_path] = menu_popup
	# 点击菜单时
	menu_popup.id_pressed.connect(_id_pressed)


func _id_pressed(id):
	var menu_path = _idx_to_menu_path_map[id]
	if is_menu_as_checkable(menu_path):
		var status = get_menu_checked(menu_path)
		set_menu_checked(menu_path, not status)
	self.menu_pressed.emit(id, menu_path)
