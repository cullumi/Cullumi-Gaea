class_name GaeaExecutionTask
extends GaeaThreadTask


var _results_dict: Dictionary[int, Dictionary]


func _set_results(value) -> void:
	_results_dict = value.get_grid_data()


func _get_results() -> Variant:
	return GaeaGrid.new(_results_dict)


func _init(_description:String, _output_resource: GaeaNodeOutput, _graph: GaeaGraph, _area: AABB):
	var _task = _output_resource.execute.bind(_area, _graph)
	super._init(_task, _description)
