@tool
extends GaeaNodeResource


func get_data(_output_port: int, area: AABBO, generator_data: GaeaData) -> Dictionary[Vector3i, float]:
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
	var neighbors: Array[Vector2i] = get_arg("neighbors", generator_data)
	var inside: bool = get_arg("inside", generator_data)

	var border: Dictionary[Vector3i, float] = {}
	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				var cell: Vector3i = Vector3i(x, y, z)
				if (inside and passed_data.get(cell) == null) or (not inside and passed_data.get(cell) != null):
					continue

				for n: Vector2i in neighbors:
					if not inside:
						var neighboring_cell: Vector3i = Vector3i(cell.x - n.x, cell.y - n.y, cell.z)
						if passed_data.get(neighboring_cell) != null:
							border.set(cell, 1)
							break
					else:
						var neighboring_cell: Vector3i = Vector3i(cell.x - n.x, cell.y - n.y, cell.z)
						if passed_data.get(neighboring_cell) == null:
							border.set(cell, 1)
							break

	return border
