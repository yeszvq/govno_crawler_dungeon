extends GdUnitTestSuite


var _health: HealthComponent


func before_test() -> void:
	_health = auto_free(HealthComponent.new())
	_health.max_health = 10
	_health.reset()


func test_damage_clamps_at_zero_and_depletes_once() -> void:
	var depleted: Array[Node] = []
	_health.depleted.connect(func(source: Node) -> void: depleted.append(source))
	_health.take_damage(7)
	_health.take_damage(7)
	_health.take_damage(7)
	assert_int(_health.current).is_equal(0)
	assert_bool(_health.is_depleted).is_true()
	assert_int(depleted.size()).is_equal(1)


func test_heal_does_not_exceed_max() -> void:
	_health.take_damage(4)
	_health.heal(100)
	assert_int(_health.current).is_equal(10)


func test_changed_reports_current_and_max() -> void:
	var reported: Array[Vector2i] = []
	_health.changed.connect(func(current: int, maximum: int) -> void: reported.append(Vector2i(current, maximum)))
	_health.take_damage(3)
	assert_array(reported).contains_exactly([Vector2i(7, 10)])
