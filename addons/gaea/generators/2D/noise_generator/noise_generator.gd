@tool
@icon("noise_generator.svg")
class_name NoiseGenerator
extends ChunkAwareGenerator2D
## Takes a Dictionary of thresholds and tiles to generate organic terrain with different tiles for different heights.
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/
## @tutorial(NoiseGenerator): https://benjatk.github.io/Gaea/#/generators/noise


@export var settings: NoiseGeneratorSettings


func _ready() -> void:
	if settings.random_noise_seed:
		settings.noise.seed = randi()

	super._ready()


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return
	var time_now : float = Time.get_unix_time_from_system()

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	if settings.random_noise_seed:
		settings.noise.seed = randi()

	erase()
	_set_grid()
	_apply_modifiers(settings.modifiers)
	var time_elapsed : float = Time.get_unix_time_from_system() - time_now
	if OS.is_debug_build():
		print_debug("Generating took %s seconds" % time_elapsed)
	grid_updated.emit()


func generate_chunk(chunk_position: Vector2i) -> void:
	if Engine.is_editor_hint() and not preview:
		return

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	erase_chunk(chunk_position)
	_set_grid_chunk(chunk_position)
	_apply_modifiers_chunk(settings.modifiers, chunk_position)

	generated_chunks.append(chunk_position)

	chunk_updated.emit(chunk_position)


func _set_grid() -> void:
	_set_grid_area(Rect2i(Vector2i.ZERO, Vector2i(settings.world_size)))


func _set_grid_chunk(chunk_position: Vector2i) -> void:
	_set_grid_area(Rect2i(
		chunk_position * chunk_size,
		Vector2i(chunk_size, chunk_size)
	))


func _set_grid_area(rect: Rect2i) -> void:
	for x in range(rect.position.x, rect.end.x):
		if not settings.infinite:
			if x < 0 or x > settings.world_size.x:
				continue

		for y in range(rect.position.y, rect.end.y):
			if not settings.infinite:
				if y < 0 or y > settings.world_size.x:
					continue

			var noise = settings.noise.get_noise_2d(x, y)
			if settings.falloff_enabled and settings.falloff_map and not settings.infinite:
				noise = ((noise + 1) * settings.falloff_map.get_value(Vector2(x, y))) - 1.0

			for threshold in settings.tiles:
				if noise > threshold:
					grid[Vector2(x, y)] = settings.tiles[threshold]
					break
