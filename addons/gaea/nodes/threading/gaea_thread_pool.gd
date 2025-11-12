class_name GaeaThreadPool
extends RefCounted


signal finished(results:GaeaThreadTask)

## The max number of this generator's [GaeaExecutionTask]s that can running in the [WorkerThreadPool] at once.
## All extra tasks will be queued to start as soon as room becomes available.
## A value of Zero means there will be no queue, and all tasks will be sent to the [WorkerThreadPool] immediately.
@export_range(0, 50, 1) var task_limit: int = 0
## The multithreading queue.
## [GaeaExecutionTasks] will wait here until the generator is ready to run them on the [WorkerThreadPool].
var _queued: Array[GaeaExecutionTask] = []
## The multithreading tasks currently in progress.
## [GaeaExecutionTasks] are tracked here until they are finished in [method _finish_completed_execution_tasks].
var _tasks: Dictionary[int, GaeaExecutionTask] = {}
## For locking shared data; enables proper setting of [ExecutionTask] results.
var _mutex: Mutex = Mutex.new()


func _init(on_finished:Callable, _task_limit:int) -> void:
	finished.connect(on_finished)
	task_limit = _task_limit


func process() -> void:
	_finish_completed_tasks()
	_run_queued_tasks()


## Send an [GaeaExecutionTask] to the [WorkerThreadPool] to start running immediately.
func _run_task(task:GaeaThreadTask):
	if task.task:
		task.log_run_time()
		
		# Spin up a task in the WorkerThreadPool.
		task.task_id = WorkerThreadPool.add_task(
			_execute, 
			false, task.description
		)
		
		# Only add to the task list if a task was made successfully.
		if task.task_id != -1:
			_tasks[task.task_id] = task


## Sends a new [GaeaExecutionTask] to the [member _task_queue] if the [member _task_limit] has been reached.
## Otherwise run it on the [WorkerThreadPool] immediately.
func queue(task: GaeaThreadTask):
	if task_limit > 0 and _tasks.size() > task_limit:
		# Queue the task to run later.
		task.log_queued_time()
		_queued.push_back(task)
	else:
		# Run the task immediately.
		_run_task(task)


## Executes generation immediately. Blocks the main thread.
func execute(task: GaeaThreadTask):
	task.task_id = 0
	task.log_run_time(false)
	_tasks[0] = task
	_execute(task)
	_finish_task(task)


## Executes the given [GaeaNodeOutput] on the given [member area].
## Passes the resulting [GaeaGrid] to [member task]'s [member GaeaExecutionTask.results].
func _execute(task: GaeaThreadTask = null):
	# Grab task data
	if task == null:
		# Wait till the task can be found using the current task id.
		var task_id: int = WorkerThreadPool.get_caller_task_id()
		while not task:
			_mutex.lock()
			if _tasks.has(task_id):
				task = _tasks[task_id]
			_mutex.unlock()
	
	# Execute
	var results = task.task.call()
	
	# Pass back results
	_mutex.lock()
	task.results = results
	_mutex.unlock()


## Finishes [GaeaExecutionTask]s as the [WorkerThreadPool] completes them.
func _finish_completed_tasks():
	for task_id in _tasks.keys():
		if task_id != 0 and WorkerThreadPool.is_task_completed(task_id):
			WorkerThreadPool.wait_for_task_completion(task_id)
			var task: GaeaExecutionTask = _tasks[task_id]
			_tasks.erase(task_id)
			_finish_task(task)


## Emits [signal generation_finished] on the given [GaeaExecutionTask]
func _finish_task(task: GaeaThreadTask):
	task.log_finish_time()
	finished.emit(task)


## Starts running queued [GaeaExecutionTask]s on the [WorkerThreadPool] as space clears up.
func _run_queued_tasks():
	while (task_limit <= 0 or _tasks.size() < task_limit) and not _queued.is_empty():
		_run_task(_queued.pop_front())
