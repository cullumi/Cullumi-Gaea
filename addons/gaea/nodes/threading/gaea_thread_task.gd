@tool
class_name GaeaThreadTask
extends RefCounted

var task: Callable
var task_id: int = -1
var description: String
var creation_time: float = -1
var queued_time: float = -1
var run_time: float = -1
var log_enabled: bool = false
var results: GaeaGrid:
	set = _set_results,
	get = _get_results


func _init(_task:Callable, _description:String, enable_log: bool = false):
	task = _task
	description = _description
	creation_time = Time.get_unix_time_from_system()
	log_enabled = enable_log


func _set_results(value) -> void:
	results = value


func _get_results() -> GaeaGrid:
	return results


func log_queued_time():
	queued_time = Time.get_unix_time_from_system()
	if log_enabled:
		print("Queued %s at time %d" % [description, queued_time])


func log_run_time(multithreaded: bool = true):
	run_time = Time.get_unix_time_from_system()
	if log_enabled:
		if queued_time != -1:
			print("Running %s after %.2d seconds in queue" % [description, run_time - queued_time])
		else:
			print("Running %s immediately on %s thread" % [description, "side" if multithreaded else "main"])


func log_start_work():
	if log_enabled:
		print.call_deferred("Working %s as task %d" % [description, WorkerThreadPool.get_caller_task_id()])


func log_finish_time():
	var finish_time = Time.get_unix_time_from_system()
	if log_enabled:
		if run_time >= 0:
			print(
				"Finished %s after %.2d seconds in WorkerThreadPool. Total lifetime %.2d seconds" %
				[description, finish_time - run_time, finish_time - creation_time]
			)
		else:
			print("Finished %s after %.2d seconds." % [description, finish_time - creation_time])
