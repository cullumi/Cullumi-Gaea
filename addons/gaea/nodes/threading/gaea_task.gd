@tool
class_name GaeaTask
extends RefCounted


var task: Callable
var task_id: int = -1
var description: String
var priority: GaeaPriority
var priority_level: float:
	get = _get_priority_level
var creation_time: float = -1.0
var queued_time: float = -1.0
var run_time: float = -1.0
var finish_time: float = -1.0
var log_enabled: bool = false
var cancelled: bool = false
var results: Variant:
	set = _set_results,
	get = _get_results


func _init(_task: Callable, _description: String, enable_log: bool = false, _priority:GaeaPriority = null):
	task = _task
	description = _description
	creation_time = Time.get_ticks_msec()
	log_enabled = enable_log
	priority = _priority


#region Priority
func _get_priority_level() -> float:
	return priority.level if priority else creation_time
#endregion


#region Results
func _set_results(value) -> void:
	results = value


func _get_results() -> Variant:
	return results
#endregion


#region Cancellation
func cancel() -> void:
	cancelled = true
	_on_cancel()


func _on_cancel() -> void:
	pass
#endregion


#region Comparison
func compare(other: GaeaTask) -> bool:
	return _compare(other)


func _compare(other: GaeaTask) -> bool:
	return creation_time < other.creation_time


func equals(other: GaeaTask) -> bool:
	return _equals(other)


func _equals(other: GaeaTask) -> bool:
	return task == other.task
#endregion


#region Logging
func log_discarded():
	if log_enabled:
		GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Discard %s." % [
			description
		])


func log_cancelled():
	finish_time = Time.get_ticks_msec()
	if log_enabled:
		GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Cancelled %s." % [
			description
		])


func log_queued_time():
	queued_time = Time.get_ticks_msec()
	if log_enabled:
		GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Queued %s at time %.2f" % [
			description,
			queued_time / 1000
		])


func log_run_time(multithreaded: bool = true):
	run_time = Time.get_ticks_msec()
	if log_enabled:
		if queued_time != -1:
			GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Running %s after %.0f ms in queue (priority %f)" % [
				description,
				(run_time - queued_time),
				priority_level,
			])
		else:
			GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Running %s immediately on %s thread (priority %f)" % [
				description,
				"side" if multithreaded else "main",
				priority_level,
			])


func log_start_work():
	if log_enabled:
		GaeaGraph.print_log.call_deferred(GaeaGraph.Log.THREADING, "Working %s as task %d" % [
			description,
			WorkerThreadPool.get_caller_task_id()
		])


func log_finish_time():
	finish_time = Time.get_ticks_msec()
	if log_enabled:
		var has_run_time := run_time >= 0
		var start_time = run_time if has_run_time else creation_time
		GaeaGraph.print_log(GaeaGraph.Log.THREADING, "Finished %s after %.0f ms%s. Total lifetime %.0f ms.%s" %
		[
			description,
			(finish_time - start_time),
			" in WorkerThreadPool" if has_run_time else "",
			(finish_time - creation_time),
			" (Canceled)" if cancelled else ""
		])
#endregion
