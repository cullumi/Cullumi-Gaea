@tool
class_name GaeaGenerationTask
extends GaeaTask

var pouch: GaeaGenerationPouch

var _results_dict: Dictionary[int, GaeaValue.Map]


@warning_ignore("shadowed_variable")
func _init(task_description: String, graph: GaeaGraph, pouch: GaeaGenerationPouch, origin = null):
	var new_task = graph.get_output_node().execute.bind(graph, pouch)
	self.pouch = pouch
	super._init(
		new_task, task_description,
		graph.is_log_enabled(GaeaGraph.Log.THREADING),
		GaeaGenerationPriority.new(origin, pouch.area),
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
	return priority_level < other.priority_level


func _equals(other: GaeaTask) -> bool:
	return pouch.area == other.pouch.area and super._equals(other)
#endregion
