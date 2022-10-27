extends Node

signal cmd_finished

var busy := false
var cmd_id := 0
var cmd_current := 0
var cmd_queue := []
var last_return_value

var enter_fn_ready := false
var enter_fn: Callable
var enter_fn_args := []


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ENTER:
			if enter_fn_ready:
				enter_fn.callv(enter_fn_args)
				enter_fn_ready = false
			get_viewport().set_input_as_handled()


func queue_command(object: Object, method: String, args: Array) -> int:
	cmd_queue.append([Callable(object, method), args])
	cmd_id += 1
	if not busy:
		_exec_command()
	return cmd_id - 1


func finish_command(value = null) -> void:
	await get_tree().process_frame
	last_return_value = value
	emit_signal("cmd_finished")
	cmd_current += 1
	busy = false
	_exec_command()


func return_value(target_id: int):
	while cmd_current < target_id:
		await cmd_finished
	return last_return_value


func wait_for_enter(object: Object, method: String, args: Array):
	enter_fn = Callable(object, method)
	enter_fn_args = args
	enter_fn_ready = true


func _exec_command():
	if cmd_queue.size() == 0:
		return

	busy = true
	var cmd: Array = cmd_queue.pop_front()
	var callable: Callable = cmd[0]
	var args: Array = cmd[1]
	callable.callv(args)
