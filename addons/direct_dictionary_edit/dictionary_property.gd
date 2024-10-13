@tool
extends EditorProperty

const DictionaryEditor: GDScript = preload("ui/dictionary_editor.gd")
var _editor: DictionaryEditor
var _edit_with_text := false


func _ready() -> void:
	_editor = preload("ui/dictionary_editor.tscn").instantiate()
	_editor.target_object = get_edited_object()
	_editor.target_variable = get_edited_property()
	_editor.parse_succeeded.connect(_on_parse_succeeded)
	call_deferred(&"add_child", _editor)


func _update_property() -> void:
	_editor.set_dictionary(_get_current_value())


func _get_current_value() -> Dictionary:
	return get_edited_object().get(get_edited_property())


func _on_parse_succeeded(data: Dictionary):
	emit_changed(get_edited_property(), data)
