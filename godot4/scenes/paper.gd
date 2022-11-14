extends Control

signal enter
signal overflow

var default_write_color := Color(0.0, 0.0, 0.0)
var default_response_color := Color("1e6ede")
var background_color := 0
var text_overflow := false

var snails := []


func _ready():
	if background_color > 1:
		$Background.texture = load("res://backgrounds/paper%d.png" % background_color)


func appear_animation() -> void:
	visible = true
	scale = Vector2(2, 2)
	modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)
	tween.parallel().tween_property(self, "scale", Vector2(1, 1), 0.2)
	await tween.finished


func write(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", default_write_color)
	$VBoxContainer.add_child(label)


func answer() -> TextEdit:
	var edit := TextEdit.new()
	edit.scroll_fit_content_height = true
	edit.caret_blink = true
	edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	edit.add_theme_color_override("font_color", default_response_color)
	$VBoxContainer.add_child(edit)
	edit.grab_focus()
	return edit


func pause() -> void:
	await enter


func move_to(dest: Vector2) -> void:
	var rand_pos := Vector2(randf_range(-20, 20), randf_range(-20, 20))
	var rand_rot := randf_range(-0.08, 0.08)
	var tween := create_tween()
	tween.tween_property(self, "position", dest + rand_pos, 0.5)
	tween.parallel().tween_property(self, "rotation", rand_rot, 0.5)
	await tween.finished


func get_snail_start_pos() -> Vector2:
	return $SnailStart.position


func remove_snail() -> void:
	for snail in snails:
		await snail.remove_snail()


func _on_container_resized():
	if not text_overflow:
		text_overflow = true
		emit_signal("overflow")
