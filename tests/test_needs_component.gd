extends GdUnitTestSuite
## Потребности убывают от игровых минут, а не каждый кадр.


var _needs: NeedsComponent


func before_test() -> void:
	_needs = auto_free(NeedsComponent.new())
	_needs.minutes_per_satiety = 15
	_needs.minutes_per_energy = 10
	add_child(_needs)


func test_needs_drop_on_game_minutes() -> void:
	for minute in range(1, 31):
		Events.game_minute_passed.emit(minute)
	assert_int(_needs.satiety).is_equal(NeedsComponent.MAX_VALUE - 2)
	assert_int(_needs.energy).is_equal(NeedsComponent.MAX_VALUE - 3)


func test_exhausted_when_reaching_zero() -> void:
	var exhausted: Array[StringName] = []
	_needs.exhausted.connect(func(need: StringName) -> void: exhausted.append(need))
	_needs.energy = 1
	Events.game_minute_passed.emit(10)
	assert_array(exhausted).contains([&"energy"])


func test_rest_restores_energy() -> void:
	_needs.energy = 5
	Events.party_rested.emit()
	assert_int(_needs.energy).is_equal(NeedsComponent.MAX_VALUE)
