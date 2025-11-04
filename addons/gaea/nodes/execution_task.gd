extends RefCounted
class_name GaeaExecutionTask

var task: Callable
var task_id: int
var description: String
var creation_time: float = -1
var queued_time: float = -1
var run_time: float = -1

var output_resource: GaeaNodeOutput
var area: AABB
var results: GaeaGrid:
	set(value): _results_dict = value.get_grid_data()
	get: return GaeaGrid.new(_results_dict)
var _results_dict: Dictionary[int, Dictionary]

func _init(_task:Callable, _description:String, _output_resource: GaeaNodeOutput, _area: AABB):
	task = _task
	description = _description
	creation_time = Time.get_unix_time_from_system()
	output_resource = _output_resource
	area = _area

func log_queued_time():
	queued_time = Time.get_unix_time_from_system()
	print("Queued %s at time %d" % [description, queued_time])

func log_run_time():
	run_time = Time.get_unix_time_from_system()
	if queued_time != -1:
		print("Running %s after %.2d seconds in queue" % [description, run_time - queued_time])
	else:
		print("Running %s immediately" % description)

func log_finish_time():
	var finish_time = Time.get_unix_time_from_system()
	if run_time >= 0:
		print("Finished %s after %.2d seconds in WorkerThreadPool. Total lifetime %.2d seconds" % [description, finish_time - run_time, finish_time - creation_time])
	else:
		print("Finished %s after %.2d seconds." % [description, finish_time - creation_time])
