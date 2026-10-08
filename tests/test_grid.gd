extends GdUnitTestSuite
## Grid и уровень: проходимость, поиск пути, точки взаимодействия.


var _camp: Level


func before_test() -> void:
	_camp = auto_free(load("res://levels/camp/camp.tscn").instantiate())
	add_child(_camp)


func test_level_attaches_itself() -> void:
	assert_object(Grid.level).is_same(_camp)


func test_walls_floor_and_props() -> void:
	assert_bool(Grid.is_walkable(Vector2i(0, 0))).is_false()
	assert_bool(Grid.is_walkable(Vector2i(3, 1))).is_true()
	# Дерево загораживает клетку.
	assert_bool(Grid.is_walkable(Vector2i(1, 1))).is_false()
	assert_int(_camp.spawn_cells.size()).is_equal(4)


func test_cell_and_world_round_trip() -> void:
	var cell := Vector2i(5, 3)
	assert_vector(Grid.cell_to_world(cell)).is_equal(Vector2(176, 112))
	assert_vector(Grid.world_to_cell(Grid.cell_to_world(cell))).is_equal(cell)


func test_path_goes_around_props() -> void:
	# Статуя стоит в (14, 7): путь слева направо её обходит.
	var path := Grid.find_path(Grid.cell_to_world(Vector2i(12, 7)), Grid.cell_to_world(Vector2i(16, 7)))
	assert_bool(path.is_empty()).is_false()
	assert_vector(path[path.size() - 1]).is_equal(Grid.cell_to_world(Vector2i(16, 7)))
	assert_bool(path.has(Grid.cell_to_world(Vector2i(14, 7)))).is_false()


func test_no_path_into_walls() -> void:
	var path := Grid.find_path(Grid.cell_to_world(Vector2i(3, 3)), Grid.cell_to_world(Vector2i(0, 3)))
	assert_bool(path.is_empty()).is_true()


func test_exit_is_an_interactable_point() -> void:
	var exits := get_tree().get_nodes_in_group(Interactable.GROUP).filter(
		func(node: Node) -> bool: return node is LevelExit
	)
	assert_int(exits.size()).is_equal(1)
	assert_vector((exits[0] as Node2D).global_position).is_equal(Grid.cell_to_world(Vector2i(11, 9)))


func test_detaches_on_exit() -> void:
	remove_child(_camp)
	assert_object(Grid.level).is_null()
	add_child(_camp)


func test_toggling_interactable_is_announced() -> void:
	var count := [0]
	var counter := func() -> void: count[0] += 1
	Events.interactables_changed.connect(counter)
	var npc_interactable: Interactable = _camp.get_node("Entities/Aldric/Interactable")
	npc_interactable.enabled = false
	Events.interactables_changed.disconnect(counter)
	assert_int(count[0]).is_equal(1)
