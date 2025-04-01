@tool
extends GaeaNodeResource


func get_data(_output_port: int, area: AABBO, generator_data: GaeaData) -> Dictionary:
	var grids: Array[Dictionary] = []
	for i: int in input_slots.size():
		if get_connected_resource_idx(i) == -1:
			continue

		var resource: GaeaNodeResource = generator_data.resources.get(get_connected_resource_idx(i))
		var grid_data: Dictionary = {}
		if is_instance_valid(resource):
			grid_data = resource.get_data(
				get_connected_port_to(i),
				area, generator_data
			)
		grids.append(grid_data)

	var grid: Dictionary = {}

	if grids.is_empty():
		return grid

	var grid_a: Dictionary = grids.pop_front()
	for cell: Vector3i in grid_a:
		for subgrid: Dictionary in grids:
			if subgrid.get(cell) != null:
				break
			grid.set(cell, grid_a.get(cell))

	return grid
