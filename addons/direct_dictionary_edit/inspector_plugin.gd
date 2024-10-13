@tool
extends EditorInspectorPlugin


func _can_handle(_object: Object) -> bool:
	return true


func _parse_property(
	_object: Object,
	type: Variant.Type,
	name: String,
	_hint_type: PropertyHint,
	_hint_string: String,
	usage_flags: int,
	_wide: bool
) -> bool:
	if (
		type == TYPE_DICTIONARY
		and usage_flags & PROPERTY_USAGE_EDITOR
		and !usage_flags & PROPERTY_USAGE_READ_ONLY
	):
		const Editor: GDScript = preload("dictionary_property.gd")
		var editor := Editor.new()
		editor.custom_minimum_size.y = 40
		add_property_editor(name, editor, true, " ")

	return false
