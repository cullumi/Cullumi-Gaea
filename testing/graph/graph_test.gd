extends GdUnitTestSuite





func test_assign_to_generator() -> void:
	var graph = load("uid://bhvhxcvp7uosa")
	var scene:WalkerDemo = load("uid://di7u4f3idjdd").instantiate()
	var _runner := scene_runner(scene)
	scene.gaea_generator.data = graph
	await scene.test_generation()


func test_duplicate() -> void:
	load("uid://bhvhxcvp7uosa")._duplicate(true)


func test_assign_duplicate() -> void:
	var graph = load("uid://bhvhxcvp7uosa")._duplicate(true)
	var scene = load("uid://di7u4f3idjdd").instantiate()
	var _runner := scene_runner(scene)
	scene.gaea_generator.data = graph
	await scene.test_generation()
