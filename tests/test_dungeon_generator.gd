extends GdUnitTestSuite
## Генератор должен быть детерминированным (по сети шлём только seed)
## и давать связную карту со всем нужным.


func test_same_seed_same_map() -> void:
	assert_str(DungeonGenerator.generate(42, 1)).is_equal(DungeonGenerator.generate(42, 1))
	assert_str(DungeonGenerator.generate(42, 1)).is_not_equal(DungeonGenerator.generate(43, 1))


func test_map_has_spawns_and_stairs() -> void:
	for level_seed in 20:
		var map := DungeonGenerator.generate(level_seed, 1)
		assert_int(map.count("P")).is_equal(4)
		assert_int(map.count(">")).is_equal(1)
		assert_int(map.count("<")).is_equal(1)


func test_all_floor_is_reachable_from_spawn() -> void:
	for level_seed in 20:
		var rows := DungeonGenerator.generate(level_seed, 2).split("\n")
		var open: Dictionary[Vector2i, bool] = {}
		var start := Vector2i(-1, -1)
		for y in rows.size():
			for x in rows[y].length():
				if rows[y][x] != "#":
					open[Vector2i(x, y)] = true
				if rows[y][x] == "P" and start.x < 0:
					start = Vector2i(x, y)
		assert_int(_flood(open, start)).is_equal(open.size())


func _flood(open: Dictionary[Vector2i, bool], start: Vector2i) -> int:
	var seen: Dictionary[Vector2i, bool] = {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_back()
		for step: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var next := cell + step
			if open.has(next) and not seen.has(next):
				seen[next] = true
				queue.append(next)
	return seen.size()
