extends GdUnitTestSuite
## Grid и уровень: проходимость, занятость клеток, поиск того, с чем говорить.


var _camp: Level


func before_test() -> void:
	_camp = auto_free(load("res://levels/camp/camp.tscn").instantiate())
	add_child(_camp)


func test_level_attaches_itself() -> void:
	assert_object(Grid.level).is_same(_camp)


func test_walls_and_floor() -> void:
	assert_bool(Grid.is_walkable(Vector2i(0, 0))).is_false()
	assert_bool(Grid.is_walkable(Vector2i(1, 1))).is_true()
	assert_int(_camp.spawn_cells.size()).is_equal(4)


func test_npc_occupies_cell_and_can_be_talked_to() -> void:
	var npc_cell := Vector2i(12, 4)
	assert_bool(Grid.is_free(npc_cell)).is_false()
	assert_object(Grid.interactable_at(npc_cell)).is_not_null()


func test_move_occupant_frees_old_cell() -> void:
	var token: Node = auto_free(Node.new())
	Grid.move_occupant(token, Vector2i(2, 2), Vector2i(2, 2))
	Grid.move_occupant(token, Vector2i(2, 2), Vector2i(3, 2))
	assert_bool(Grid.is_free(Vector2i(2, 2))).is_true()
	assert_object(Grid.occupant_at(Vector2i(3, 2))).is_same(token)


func test_exits_are_floor_interactables() -> void:
	var exit_cell := Vector2i(7, 8)
	assert_bool(Grid.is_free(exit_cell)).is_true()
	assert_object(Grid.interactable_at(exit_cell)).is_instanceof(LevelExit)


func test_detaches_on_exit() -> void:
	remove_child(_camp)
	assert_object(Grid.level).is_null()
	add_child(_camp)
