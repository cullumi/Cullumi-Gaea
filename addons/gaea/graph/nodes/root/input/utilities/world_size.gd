@tool
extends GaeaNodeResource


func get_data(_output_port: int, _area: AABBO, generator_data: GaeaData) -> Dictionary:
	if not is_instance_valid(generator_data.generator):
		return {"value": Vector3.ZERO}
	return {
		"value": generator_data.generator.world_size
	}
