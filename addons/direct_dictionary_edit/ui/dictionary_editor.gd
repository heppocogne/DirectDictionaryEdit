@tool
extends VBoxContainer

signal parse_succeeded(data: Dictionary)

var target_object: Object
var target_variable: StringName
var _try_parse := false
var _self_update := false

@onready var _editor: CodeEdit = $CodeEdit


func _ready() -> void:
	if target_object != null:
		var data: Dictionary = target_object.get(target_variable)
		set_dictionary(data)


func set_dictionary(dict: Dictionary):
	if !_self_update and _editor != null:
		# TODO: Support Transform2D/3D
		_editor.text = _get_indented(var_to_str(dict))
	_self_update = false


static func _get_indented(s: String) -> String:
	var indent := 0
	var result := ""
	for line in s.split('\n'):
		if line == '}' or line == "},":
			indent = maxi(0, indent - 1)
		for _i in indent:
			result += '\t'
		result += line + '\n'
		if line.ends_with('{'):
			indent += 1
	
	return result


func _parse_text(source: String):
	var check_func := RegEx.new()
	check_func.compile("^\t*(static)?[\t ]*func")
	var check_setter := RegEx.new()
	check_setter.compile("^[\t ]*set")
	if check_func.search(source) || check_setter.search(source):
		return null
	
	var gdscript := GDScript.new()
	gdscript.source_code = "@tool\nvar data:Dictionary = %s" % [source]
	gdscript.reload()
	if gdscript.can_instantiate():
		var obj := RefCounted.new()
		obj.set_script(gdscript)
		if &"data" in obj:
			return obj.data
	
	return null


func _on_text_set() -> void:
	if _self_update:
		return
	var data = _parse_text(_editor.text)
	if typeof(data) == TYPE_DICTIONARY:
		parse_succeeded.emit(data)
	else:
		push_error("cannot parse expression: \n%s\n" % [_editor.text])


func _on_button_pressed() -> void:
	var data = _parse_text(_editor.text)
	if typeof(data) == TYPE_DICTIONARY:
		parse_succeeded.emit(data)
	else:
		push_error("cannot parse expression: \n%s\n" % [_editor.text])
