@tool
@icon("../assets/slots/triangle.svg")
class_name GaeaGenerationPriority
extends GaeaPriority


var _origin
var _pouch: GaeaGenerationPouch


func _init(origin, _gen_pouch: GaeaGenerationPouch) -> void:
	_origin = origin
	_pouch = _gen_pouch


func _calculate() -> float:
	return _get_origin().distance_to(_convert_vector(_pouch.area.position/_pouch.area.size))


func _get_origin() -> Vector4:
	var value = _origin
	if _origin is Callable:
		value = _origin.call()
	if value is Node:
		if value is Node2D or value is Node3D or value is Control:
			return _convert_vector(value.global_position)
		return Vector4.ZERO
	return _convert_vector(value)


const has_valid_w: Array[Variant.Type] = [TYPE_VECTOR4, TYPE_VECTOR4I]
const has_valid_z: Array[Variant.Type] = [TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]
const has_valid_x: Array[Variant.Type] = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]
const has_valid_y: Array[Variant.Type] = [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I]

func _convert_vector(vector) -> Vector4:
	var v_type = typeof(vector)
	var x = 0
	if v_type in has_valid_x:
		x = vector.x
	var y = 0
	if v_type in has_valid_y:
		y = vector.y
	var z = 0
	if v_type in has_valid_z:
		z = vector.z
	var w = 0
	if v_type in has_valid_w:
		w = vector.w
	return Vector4(x, y, z, w)
