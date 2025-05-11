extends RefCounted

class_name StepCounter

var steps_taken:String = ""
var _event_count = 0
var _uninterrupted_steps:int = 0
var _interrupted:bool = false
var _events_per_line:int

func _init(events_per_line:int) -> void:
	_events_per_line = events_per_line

## To be called when each countable step completes.
func mark_loop():
	if not _interrupted:
		_uninterrupted_steps += 1
	_interrupted = false

## To be called whenever an interruption to the standard flow occurs.
func mark_interruption():
	if _uninterrupted_steps > 0:
		mark_event("%d" % _uninterrupted_steps, false)
	_uninterrupted_steps = 0
	_interrupted = true

## To be called for marking unique events; marks and interruption by default.
func mark_event(event:String, interrupt:bool = true, event_amount:int = 1):
	if interrupt and not _interrupted:
		mark_interruption()
	_event_count += event_amount
	if _event_count % _events_per_line == 1:
		steps_taken += "\n"
	steps_taken += "%s " % event
