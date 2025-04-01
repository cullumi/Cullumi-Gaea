extends CharacterBody2D

@export var speed:float = 100
var dir:Vector2 = Vector2.ZERO
@export var move: Dictionary[String, bool] = {
	"move_left":false, "move_right":false, "move_up":false, "move_down":false
}

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	for key in move.keys():
		if (get_viewport().is_input_handled()):
			return
		move[key] = pressed(event, key, move[key])

func pressed(event: InputEvent, action: String, default: bool):
	if (event.is_action_pressed(action)):
		get_viewport().set_input_as_handled()
		return true
	elif (event.is_action_released(action)): 
		get_viewport().set_input_as_handled()
		return false
	else: return default

func direction():
	var left:int = -1 if move.move_left else 0
	var right:int = 1 if move.move_right else 0
	var up:int   = -1 if move.move_up else 0
	var down:int  = 1 if move.move_down else 0
	return Vector2(left + right, down + up)

func _process(delta: float) -> void:
	dir = direction()

func _physics_process(delta: float) -> void:
	velocity = dir * speed
	move_and_slide()
