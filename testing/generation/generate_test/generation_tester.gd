extends Node2D

class_name GaeaGenerationTester

@onready var gaea_generator: GaeaGenerator = $GaeaGenerator

var last_grid: GaeaGrid
var timer: SceneTreeTimer

signal generation_ended

## Used for integration testing.
func test_generation(fixed_seed: int = 0) -> void:
	gaea_generator.settings.world_size = Vector3i(45, 45, 1)
	gaea_generator.settings.random_seed_on_generate = false
	gaea_generator.settings.seed = fixed_seed
	gaea_generator.generation_finished.connect(_set_last_grid)
	gaea_generator.generation_finished.connect(_on_generation_finished)
	timer = get_tree().create_timer(5)
	timer.timeout.connect(_on_generation_finished.bind(null))
	gaea_generator.generate()
	await generation_ended

func _on_generation_finished(result):
	timer.timeout.disconnect(_on_generation_finished.bind(null))
	gaea_generator.generation_finished.disconnect(_set_last_grid)
	gaea_generator.generation_finished.disconnect(_on_generation_finished)
	if result == null:
		gaea_generator.cancel_generation()
		_set_last_grid(null)
	generation_ended.emit()

func _set_last_grid(grid):
	last_grid = grid

func _on_generate_pressed() -> void:
	gaea_generator.generate()
