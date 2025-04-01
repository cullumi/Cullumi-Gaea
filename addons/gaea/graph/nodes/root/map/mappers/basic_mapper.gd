@tool
extends GaeaNodeResource


func get_data(_output_port: int, area: AABBO, generator_data: GaeaData) -> Dictionary[Vector3i, GaeaMaterial]:
	var data_connected_idx: int = get_connected_resource_idx(0)
	if data_connected_idx == -1:
		return {}

	var data_input_resource: GaeaNodeResource = generator_data.resources.get(data_connected_idx)
	if not is_instance_valid(data_input_resource):
		return {}

	var passed_data: Dictionary = data_input_resource.get_data(
		get_connected_port_to(0),
		area, generator_data
	)
	var material: GaeaMaterial = null

	var material_connected_idx: int = get_connected_resource_idx(1)
	if material_connected_idx != -1:
		var material_input_resource: GaeaNodeResource = generator_data.resources.get(material_connected_idx)
		if is_instance_valid(material_input_resource):
			material = material_input_resource.get_data(
				get_connected_port_to(1),
				area, generator_data
			).get("value", null)
	var grid: Dictionary[Vector3i, GaeaMaterial]

	for cell in passed_data:
		if _passes_mapping(passed_data, cell, generator_data) and is_instance_valid(material):
			grid[cell] = material.get_resource()

	return grid


func _passes_mapping(passed_data: Dictionary, cell: Vector3i, _generator_data: GaeaData) -> bool:
	return passed_data.get(cell) != null
