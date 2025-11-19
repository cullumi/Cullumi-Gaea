extends EditorInspectorPlugin

const GradientVisualizer = preload("uid://cwaqlwiy2t1pe")
const GeneratorButtons = preload("uid://dm42lg3fiyqub")


func _can_handle(object: Object) -> bool:
	return (
		object is GradientGaeaMaterial
		or object is GaeaGenerator
	)


func _parse_begin(object: Object) -> void:
	if object is GradientGaeaMaterial:
		var gradient_visualizer := GradientVisualizer.new()
		gradient_visualizer.gradient = object

		add_custom_control(gradient_visualizer)

		gradient_visualizer.update()
		object.points_sorted.connect(gradient_visualizer.update)


func _parse_category(object: Object, category: String) -> void:
	if object is GaeaGenerator and category == &"generator.gd":
		var generator_buttons := GeneratorButtons.new()
		generator_buttons.generator = object

		add_custom_control(generator_buttons)
