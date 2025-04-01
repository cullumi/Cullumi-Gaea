@tool
extends GaeaNodeResource


func get_data(_output_port: int, area: AABBO, generator_data: GaeaData) -> Dictionary[Vector3i, GaeaMaterial]:
	var data_connected_idx: int = get_connected_resource_idx(0)
	var passed_data: Dictionary = {}
	if data_connected_idx != -1:
		var data_input_resource: GaeaNodeResource = generator_data.resources.get(data_connected_idx)
		if not is_instance_valid(data_input_resource):
			return {}

		passed_data = data_input_resource.get_data(
			get_connected_port_to(0),
			area, generator_data
		)
	var material: GaeaMaterial = null
	seed(area_seed(area, generator_data))

	var material_connected_idx: int = get_connected_resource_idx(1)
	if material_connected_idx != -1:
		var material_input_resource: GaeaNodeResource = generator_data.resources.get(material_connected_idx)
		if is_instance_valid(material_input_resource):
			material = material_input_resource.get_data(
				material_connected_idx,
				area, generator_data
			).get("value", null)
	var grid: Dictionary[Vector3i, GaeaMaterial]
	var cells_to_place_on: Array = passed_data.keys()
	cells_to_place_on.shuffle()
	cells_to_place_on.resize(mini(get_arg("amount", generator_data), cells_to_place_on.size()))

	for cell: Vector3i in cells_to_place_on:
		grid.set(cell, null if not is_instance_valid(material) else material.get_resource())

	return grid
