@tool
@icon("../assets/slots/triangle.svg")
class_name GaeaGenerationPriority
extends GaeaPriority


var origin: Variant

var area: AABB


@warning_ignore("shadowed_variable")
func _init(origin: Variant, area: AABB) -> void:
	self.origin = origin
	area = area


func _calculate() -> float:
	var position := Vector.to_vec4(area.position / area.size)
	return _get_origin().distance_squared_to(position)


func _get_origin() -> Vector4:
	var value = origin
	if origin is Callable:
		value = origin.call()
	if value is Node:
		if value is Node2D or value is Node3D or value is Control:
			return Vector.to_vec4(value.global_position)
		return Vector4.ZERO
	return Vector.to_vec4(value)


class Vector:
	const HAS_VALID_W: Array[Variant.Type] = [TYPE_VECTOR4, TYPE_VECTOR4I]
	const HAS_VALID_Z: Array[Variant.Type] = [TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]
	const HAS_VALID_Y: Array[Variant.Type] = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]
	const HAS_VALID_X: Array[Variant.Type] = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]

	static func to_vec4(vector: Variant) -> Vector4:
		var v_type := typeof(vector)
		var x := 0.0
		if v_type in HAS_VALID_X:
			x = vector.x
		var y := 0.0
		if v_type in HAS_VALID_Y:
			y = vector.y
		var z := 0.0
		if v_type in HAS_VALID_Z:
			z = vector.z
		var w := 0.0
		if v_type in HAS_VALID_W:
			w = vector.w
		return Vector4(x, y, z, w)
