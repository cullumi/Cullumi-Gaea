extends RefCounted

class_name AABBO

var end: Vector3:
	set(value): aabb.end = value
	get: return aabb.end
var position: Vector3:
	set(value): aabb.position = value
	get: return aabb.position
var size: Vector3:
	set(value): aabb.size = value
	get: return aabb.size
var area: AABB:
	set(value): aabb = AABB(aabb.position - offset, aabb.size)
	get: return AABB(aabb.position + offset, aabb.size)

var offset: Vector3
var aabb: AABB

@warning_ignore("shadowed_variable")
func _init(from: AABB=AABB(), offset: Vector3=Vector3()):
	self.aabb = from
	self.offset = offset
