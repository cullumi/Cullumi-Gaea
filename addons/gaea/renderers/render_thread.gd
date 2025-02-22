@tool

class_name RenderThread
extends GaeaRenderer

## Emitted when anything is rendered, be it a chunk or the full grid.
signal area_rendered(area)
## Emitted when a chunk is rendered.
signal chunk_rendered(chunk_position)

## The GaeaRenderer2D that will be run via this RenderThread2D.
@export var render_target: GaeaRenderer :
	set(value):
		_disconnect_signals()
		if render_target:
			render_target._connect_signals()
		
		render_target = value
		
		if is_instance_valid(render_target):
			if not render_target.is_node_ready() and not is_node_ready():
				return
			print("Doing things?")
			if render_target.generator:
				generator = render_target.generator
			_connect_signals()
		update_configuration_warnings()
## Whether or not to pass calls through to the default TilemapGaeaRenderer,
##  instead of threading them.
@export var threaded: bool = true
## Decides the maximum number of WorkerThreadPool tasks that can be created
##  before queueing new tasks. A negative value (-1) means there is no limit.
@export_range(-1, 1000, 1, "exp", "or_greater") var task_limit: int = -1


var _queued: Array[Callable] = []
var _tasks: PackedInt32Array = []


func _process(_delta):
	for t in range(_tasks.size()-1, -1, -1):
		if WorkerThreadPool.is_task_completed(_tasks[t]):
			WorkerThreadPool.wait_for_task_completion(_tasks[t])
			_tasks.remove_at(t)
	if threaded:
		while task_limit >= 0 and _tasks.size() < task_limit and not _queued.is_empty():
			run_task(_queued.pop_front())


func run_task(_task:Callable):
	if _task:
		print("Running task?")
		_tasks.append(WorkerThreadPool.add_task(_task, false, "Draw Area"))


func call_threaded(method:String, args:Array) -> void:
	var _new_task:Callable = func ():
		render_target.callv(method, args)

	if task_limit >= 0 and _tasks.size() >= task_limit:
		_queued.push_back(_new_task)
	else:
		run_task(_new_task)


# Helpers
#func valid_area(area):
	#return area as Rect2i if render_target is GaeaRenderer2D else area as AABB
#
#func valid_chunk_position(position):
	#return position as Vector2i if render_target is GaeaRenderer2D else position as Vector3i

# Gaea Renderer 2D and 3D Interface

## Draws the [param area]. Override this function
## to make custom [GaeaRenderer]s.
func _draw_area(area) -> void:
	if not threaded:
		render_target._draw_area(area)
	else:
		call_threaded("_draw_area", [area])


## Draws the chunk at [param chunk_position].
func _draw_chunk(chunk_position) -> void:
	if not threaded:
		render_target._draw_chunk(chunk_position)
	else:
		call_threaded("_draw_chunk", [chunk_position])


## Draws the whole grid.
func _draw() -> void:
	if not threaded:
		render_target._draw()
	else:
		call_threaded("_draw", [])


func _render_target_signals_connected() -> void:
	print("Disconnecting Render Target Signals")
	render_target._disconnect_signals()


func _connect_signals() -> void:
	if render_target and not render_target.signals_connected.is_connected(_render_target_signals_connected):
		render_target._disconnect_signals()
		render_target.signals_connected.connect(_render_target_signals_connected)

	if generator and generator.has_signal("chunk_updated"):
		if not generator.chunk_updated.is_connected(_draw_chunk):
			generator.chunk_updated.connect(_draw_chunk)
	
	super()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	if not is_instance_valid(render_target):
		warnings.append("Needs a Gaea Renderer to work.")

	return warnings
