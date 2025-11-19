@tool
class_name GaeaGenerationTask
extends GaeaTask

var pouch: GaeaGenerationPouch

var _results_dict: Dictionary[int, GaeaValue.Map]


func _set_results(value) -> void:
	_results_dict = value.get_grid_data()


func _get_results() -> Variant:
	return GaeaGrid.new(_results_dict)


func _on_cancel() -> void:
	if is_instance_valid(pouch):
		pouch.cancelled = true


func _init(task_description: String, graph: GaeaGraph, generation_pouch: GaeaGenerationPouch):
	var new_task = graph.get_output_node().execute.bind(graph, generation_pouch)
	pouch = generation_pouch
	super._init(new_task, task_description, graph.is_log_enabled(GaeaGraph.Log.THREADING))
