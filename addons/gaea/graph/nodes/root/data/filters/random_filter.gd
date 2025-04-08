@tool
extends "filter.gd"


func _passes_filter(passed_data: Dictionary, cell: Vector3i, generator_data: GaeaData) -> bool:
	var chance: float = float(get_arg("chance", generator_data)) / 100.0
	return randf() <= chance
