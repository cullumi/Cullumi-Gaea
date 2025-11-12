@tool
@icon("../assets/generator.svg")
class_name GaeaGenerator
extends Node
## Generates a grid of [GaeaMaterial]s using the graph at [member graph] to be rendered by a
## [GaeaRendered] or used in other ways.


## Emitted when [GaeaGraph] is changed.
signal graph_changed
## Emitted when the graph is about to generate.
signal about_to_generate
## Emitted when the graph is done with the generation.
@warning_ignore("unused_signal")
signal generation_finished(grid: GaeaGrid)
## Emitted when this generator wants to trigger a reset. See [method GaeaRenderer._reset].
signal reset_requested
## Emitted when an [param area] is erased.
signal area_erased(area: AABB)


@warning_ignore("unused_private_class_variable")
@export_tool_button("Generate", "Play") var _button_generate = generate
@warning_ignore("unused_private_class_variable")
@export_tool_button("Clear", "Remove") var _button_clear = request_reset


## The [GaeaGraph] used for generation.
@export var graph: GaeaGraph:
	set(value):
		graph = value
		if is_instance_valid(graph):
			graph.ensure_initialized()
		graph_changed.emit()

@export var settings: GaeaGenerationSettings

## Whether this generator should block the main thread.
@export var multithreaded: bool = true

## The max number of this generator's [GaeaExecutionTask]s that can running in the [WorkerThreadPool] at once.
## All extra tasks will be queued to start as soon as room becomes available.
## A value of Zero means there will be no queue, and all tasks will be sent to the [WorkerThreadPool] immediately.
@export_range(0, 50, 1) var task_limit: int = 0 :
	set(value):
		task_limit = value
		if _thread_pool:
			_thread_pool.task_limit = value

## The thread pool used by the Generator to perform tasks on multiple threads,
## with the help fo the builtin [WorkerThreadPool].
@onready var _thread_pool: GaeaThreadPool


# For migration to GaeaGenerationSettings
func _set(property: StringName, value: Variant) -> bool:
	match property:
		&"data":
			graph = value
			return true
		&"random_seed_on_generate", &"seed", &"world_size", &"cell_size":
			_migrate_settings_property(property, value)
			return true
	return false


func _migrate_settings_property(property: StringName, value: Variant):
	if settings == null:
		settings = GaeaGenerationSettings.new()
	settings.set(property, value)


## Start the generaton process. First resets the current generation, then generates the whole
## [member world_size].
func generate() -> void:
	about_to_generate.emit()
	if settings.random_seed_on_generate:
		settings.seed = randi()
	request_reset()
	generate_area(AABB(Vector3.ZERO, settings.world_size))


## Generate an [param area] using the graph saved in [member graph].
func generate_area(area: AABB) -> void:
	var pouch: GaeaGenerationPouch = GaeaGenerationPouch.new(settings, area)
	generation_finished.emit.call_deferred(graph.get_output_node().execute(graph, pouch))
	pouch.clear_all_cache()
	
	if not _thread_pool:
		_thread_pool = GaeaThreadPool.new(_execution_task_finished, task_limit)
	
	var task := GaeaExecutionTask.new(
		"Execute on %s" % area,
		output_resource, data, area
	)
	
	if multithreaded:
		_thread_pool.queue(task)
	else:
		_thread_pool.execute(task)


## Emits [signal generation_finished] on the given results of the given [GaeaExecutionTask]
func _execution_task_finished(task: GaeaThreadTask):
	#assert(task_results is GaeaGraph)
	assert(task is GaeaExecutionTask)
	print("Finishing execution, result has %d elements." % task.results.get_grid_data().size())
	generation_finished.emit.call_deferred(task.results)
	data.cache.clear()


func _process(_delta: float) -> void:
	if _thread_pool:
		_thread_pool.process()


## Emits [signal area_erased]. Does nothing by itself, but notifies [GaeaRenderer]s that they should
## erase the points of [param area].
func request_area_erasure(area: AABB) -> void:
	area_erased.emit.call_deferred(area)


## Returns [param position] in cell coordinates based on [member cell_size].
func global_to_map(position: Vector3) -> Vector3i:
	return (position / Vector3(settings.cell_size)).floor()


## Emits [signal reset_requested]. Does nothing by itself, but notifies [GaeaRenderer]s that they should
## reset the current generation.
func request_reset() -> void:
	reset_requested.emit()
