@tool
class_name GaeaGenerationTask
extends GaeaTask

var pouch: GaeaGenerationPouch

var _results_dict: Dictionary[int, GaeaValue.Map]


func _init(task_description: String, graph: GaeaGraph, _pouch: GaeaGenerationPouch, _origin = null):
	var new_task = graph.get_output_node().execute.bind(graph, _pouch)
	pouch = _pouch
	super._init(
		new_task, task_description,
		graph.is_log_enabled(GaeaGraph.Log.THREADING),
		GaeaGenerationPriority.new(_origin, _pouch),
	)


#region Results
func _set_results(value) -> void:
	_results_dict = value.get_grid_data()


func _get_results() -> Variant:
	return GaeaGrid.new(_results_dict)
#endregion


#region Cancellation
func _on_cancel() -> void:
	if is_instance_valid(pouch):
		pouch.cancelled = true
#endregion


#region Comparison
func _compare(other: GaeaTask) -> bool:
	return pouch.priority < other.pouch.priority


func _equals(other: GaeaTask) -> bool:
	return pouch.area == other.pouch.area and super._equals(other)
#endregion
