@tool
@icon("../assets/slots/triangle.svg")
class_name GaeaPriority
extends RefCounted
var level: float :
	get = _calculate


@warning_ignore("shadowed_variable")
func _init(level: float) -> void:
	self.level = level


func _set_value(value) -> void:
	level = value


func _calculate() -> float:
	return level
