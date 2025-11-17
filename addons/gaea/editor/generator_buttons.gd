@tool
extends PanelContainer

var generate_button: Button
var clear_button: Button

var generator: GaeaGenerator

func _enter_tree() -> void:
	var vbox := VBoxContainer.new()
	add_child(vbox)
	
	generate_button = Button.new()
	generate_button.text = "Generate"
	generate_button.pressed.connect(_generate)
	generator.generation_finished.connect(reset)

	vbox.add_child(generate_button)
	
	clear_button = Button.new()
	clear_button.text = "Clear"
	clear_button.pressed.connect(_clear)
	vbox.add_child(clear_button)


func _generate() -> void:
	print("Generating...")
	generate_button.disabled = false
	generate_button.queue_redraw()
	generator.generate()


func _clear() -> void:
	print("Clearing generator")
	generator.request_reset()


func reset(_discrd) -> void:
	print("Reset generator buttons %s" % (_discrd as GaeaGrid).get_layers_count())
	generate_button.disabled = true
