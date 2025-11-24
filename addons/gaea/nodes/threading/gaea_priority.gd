@tool
@icon("../assets/slots/triangle.svg")
class_name GaeaPriority
extends RefCounted


const MAX_FLOAT = 3.4028235e38


var level: float :
	get = _calculate


func _init(_level: int) -> void:
	level = _level


func _set_value(value) -> void:
	level = value


func _calculate() -> float:
	return level
