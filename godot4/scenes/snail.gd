extends Sprite2D

const min_step_time := 0.05

var lines := []
var update_line := false
var step_time := 0.0
var pixels_per_unit := 1
var lines_parent_node: Node2D
var dots_parent_node: Node2D
var ink_color := Color("83c623")


func _ready():
	_add_line()


func _process(_delta: float):
	if update_line:
		var line: Line2D = lines[-1]
		line.set_point_position(line.get_point_count() - 1, position)


func _add_line() -> void:
	var line := Line2D.new()
	lines.append(line)
	line.width = 3
	line.default_color = ink_color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	lines_parent_node.add_child(line)
	line.add_point(position)


func remove_snail() -> void:
	queue_free()


# ---------------------------------------------------------
# User functions
# ---------------------------------------------------------

func walk(units: float) -> void:
	Global.queue_command(self, "_walk", [units])


func jump(units: float) -> void:
	Global.queue_command(self, "_jump", [units])


func goto(x: float, y: float) -> void:
	Global.queue_command(self, "_goto", [x, y])


func right(angle: float) -> void:
	Global.queue_command(self, "_right", [angle])


func left(angle: float) -> void:
	Global.queue_command(self, "_right", [-angle])


func dot() -> void:
	Global.queue_command(self, "_dot", [])


func color(c: Color) -> void:
	Global.queue_command(self, "_color", [c])


func exit() -> void:
	Global.queue_command(self, "_exit", [])


# ---------------------------------------------------------


func _walk(units: float) -> void:
	var line: Line2D = lines[-1]
	var end_position := position + Vector2.UP.rotated(rotation) * units * pixels_per_unit
	if step_time < min_step_time:
		position = end_position
		line.add_point(end_position)
		Global.finish_command()
	else:
		line.add_point(position)
		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "position", end_position, step_time)
		update_line = true
		tween.play()
		tween.connect("finished", _walk_finish)


func _walk_finish() -> void:
	var line: Line2D = lines[-1]
	line.set_point_position(line.get_point_count() - 1, position)
	update_line = false
	Global.finish_command()


func _jump(units: float) -> void:
	var target := position + Vector2.UP.rotated(rotation) * units
	_goto(target.x, target.y)


func _goto(x: float, y: float) -> void:
	var end_position := Vector2(x, y) * pixels_per_unit
	if step_time < min_step_time:
		position = end_position
		_add_line()
		Global.finish_command()
	else:
		_add_line()
		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "position", end_position, step_time)
		tween.play()
		tween.connect("finished", _goto_finish)


func _goto_finish() -> void:
	var line: Line2D = lines[-1]
	line.set_point_position(line.get_point_count() - 1, position)
	Global.finish_command()


func _right(angle: float) -> void:
	var angle_rad = deg_to_rad(angle)
	if step_time < min_step_time:
		rotation += angle_rad
		Global.finish_command()
	else:
		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "rotation", rotation + angle_rad, step_time)
		tween.play()
		tween.connect("finished", _right_finish)


func _right_finish() -> void:
	Global.finish_command()


func _dot() -> void:
	var dot_node := Sprite2D.new()
	dot_node.texture = preload("res://sprites/dot.png")
	dot_node.modulate = ink_color
	dot_node.position = position
	dots_parent_node.add_child(dot_node)
	Global.finish_command()


func _color(c: Color) -> void:
	ink_color = c
	if lines[-1].get_point_count() > 1:
		_add_line()
	else:
		lines[-1].default_color = c
	Global.finish_command()


func _exit():
	remove_snail()
	Global.finish_command()
