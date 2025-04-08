@tool
extends GaeaNodeResource
class_name GaeaVariableNodeResource


@export var type: Variant.Type
@export var hint: PropertyHint
@export var hint_string: String
@export var output_type: GaeaGraphNode.SlotTypes


func get_data(_passed_data:Array[Dictionary], _output_port: int, _area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(_output_port, generator_data)
	return generator_data.parameters.get(get_arg("name", null))


static func get_scene() -> PackedScene:
	return preload("uid://bodjhgqp1bpui") # Variable Node Scene


func get_type() -> GaeaGraphNode.SlotTypes:
	match type:
		TYPE_FLOAT, TYPE_INT:
			return GaeaGraphNode.SlotTypes.NUMBER
		TYPE_VECTOR2, TYPE_VECTOR2I:
			return GaeaGraphNode.SlotTypes.VECTOR2
		TYPE_BOOL:
			return GaeaGraphNode.SlotTypes.BOOL
		TYPE_OBJECT:
			if hint_string == "GaeaMaterial":
				return GaeaGraphNode.SlotTypes.TILE_INFO
		TYPE_VECTOR3, TYPE_VECTOR3I:
			return GaeaGraphNode.SlotTypes.VECTOR3
	return GaeaGraphNode.SlotTypes.NULL


func get_icon() -> Texture2D:
	match type:
		TYPE_FLOAT:
			return preload("uid://baw7ye0h4xdcx") # Float
		TYPE_INT:
			return preload("uid://bilsfh3nrbhkl") # Int
		TYPE_VECTOR2:
			return preload("uid://c8uvy6c2syjk5") # Vec2
		TYPE_VECTOR2I:
			return preload("uid://bpel4ys42dkjc") # Vec2i
		TYPE_BOOL:
			return preload("uid://0l53mu4blspj") # Bool
		TYPE_OBJECT:
			if hint_string == "GaeaMaterial":
				return preload("uid://b0vqox8bodse") # Material
		TYPE_VECTOR3:
			return preload("uid://bkknri7u8ghs4") # Vec3
		TYPE_VECTOR3I:
			return preload("uid://cd0polwxfqhyi") # Vec3i
	return null
