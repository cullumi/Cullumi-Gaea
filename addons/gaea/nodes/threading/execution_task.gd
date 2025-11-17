class_name GaeaExecutionTask
extends GaeaThreadTask


var _results_dict: Dictionary[int, GaeaValue.Map]
var pouch: GaeaGenerationPouch


func _set_results(value) -> void:
	_results_dict = value.get_grid_data()


func _get_results() -> Variant:
	return GaeaGrid.new(_results_dict)


func _init(_description:String, _graph:GaeaGraph, _pouch:GaeaGenerationPouch):
	var new_task = _graph.get_output_node().execute.bind(_graph, _pouch)
	pouch = _pouch
	super._init(new_task, _description)
