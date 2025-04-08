@tool
extends "filter.gd"


func _passes_filter(passed_data: Dictionary, cell: Vector3i, generator_data: GaeaData) -> bool:
	var flags: Array = get_arg("match_flags", generator_data)
	var exclude_flags: Array = get_arg("exclude_flags", generator_data)
	var match_all: bool = get_arg("match_all", generator_data)

	var value: float = passed_data[cell]
	if match_all:
		return flags.all(_matches_flag.bind(value)) and not exclude_flags.any(_matches_flag.bind(value))
	else:
		return flags.any(_matches_flag.bind(value)) and not exclude_flags.any(_matches_flag.bind(value))


func _matches_flag(value: float, flag: int) -> bool:
	return roundi(value) & flag
