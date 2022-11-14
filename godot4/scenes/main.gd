extends Control

const left_paper_position := Vector2(460, 540)
const right_paper_position := Vector2(1320, 540)

var paper_list := []


func _ready():
	new_page()
	if has_method("start"):
		self.start()


# ---------------------------------------------------------
# User functions
# ---------------------------------------------------------

func write(text: String) -> void:
	Global.queue_command(self, "_write", [text])


func answer() -> String:
	var id := Global.queue_command(self, "_answer", [])
	return await Global.return_value(id)


func pause(seconds: float = 0.0) -> void:
	Global.queue_command(self, "_pause", [seconds])


func new_page() -> void:
	Global.queue_command(self, "_new_page", [])


func new_snail() -> Sprite2D:
	var id := Global.queue_command(self, "_new_snail", [])
	return await Global.return_value(id)


func clone(snail: Sprite2D) -> Sprite2D:
	var id := Global.queue_command(self, "_clone", [snail])
	return await Global.return_value(id)

# ---------------------------------------------------------


func _write(text: String) -> void:
	paper_list[-1].write(text)
	Global.finish_command()


func _answer() -> void:
	var edit: TextEdit = paper_list[-1].answer()
	Global.wait_for_enter(self, "_finish_answer", [edit])

func _finish_answer(edit: TextEdit) -> void:
	edit.editable = false
	Global.finish_command(edit.text)


func _pause(seconds: float) -> void:
	if seconds > 0:
		var timer := get_tree().create_timer(seconds)
		timer.connect("timeout", _pause_finish)
	else:
		Global.wait_for_enter(self, "_pause_finish", [])


func _pause_finish() -> void:
	Global.finish_command()


func _new_page() -> void:
	var paper := preload("res://scenes/paper.tscn").instantiate()
	paper.connect("overflow", _paper_overflow)
	if paper_list.size() > 0:
		if paper_list.size() > 1:
			await paper_list[-1].remove_snail()
			await paper_list[-1].move_to(left_paper_position)
		paper.position = right_paper_position
		paper.visible = false
		paper.background_color = (paper_list.size() % 4) + 1
		paper_list.append(paper)
		add_child(paper)
		await paper.appear_animation()
	else:
		paper.position = left_paper_position
		paper_list.append(paper)
		add_child(paper)
	Global.finish_command()


func _new_snail() -> void:
	var paper: Control = paper_list[-1]
	var snail := preload("res://scenes/snail.tscn").instantiate()
	snail.position = paper.get_snail_start_pos()
	snail.lines_parent_node = paper.get_node("Lines")
	snail.dots_parent_node = paper.get_node("Dots")
	paper.add_child(snail)
	paper.snails.append(snail)
	Global.finish_command(snail)


func _clone(snail: Sprite2D) -> void:
	var snail2: Sprite2D = await new_snail()
	snail2.position = snail.position
	snail2.rotation = snail.rotation
	snail2.ink_color = snail.ink_color
	Global.finish_command(snail2)


func _paper_overflow() -> void:
	Global.exec_priority_command(self, "_new_page", [])
