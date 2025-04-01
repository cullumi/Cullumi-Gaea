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

	var rules: Dictionary = get_arg("rules", generator_data)

	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				var place: bool = true
				var cell: Vector3i = Vector3i(x, y, z)
				for offset: Vector2i in rules:
					var offset_3d: Vector3i = Vector3i(offset.x, offset.y, 0)
					if _is_point_outside_area(area.area, cell + offset_3d):
						place = false
						break

					if (passed_data.get(cell + offset_3d) != null) != rules.get(offset):
						place = false
						break
				if place:
					grid.set(cell, null if not is_instance_valid(material) else material.get_resource())

	return grid
