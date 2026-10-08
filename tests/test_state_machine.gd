extends GdUnitTestSuite
## Стейт-машина: переходы по таблице, свои обработчики, can_enter, resume.


class FakeSource extends IntentSource:
	pass


class RecordingState extends State:
	var log: Array[String] = []
	var allowed := true

	func can_enter() -> bool:
		return allowed

	func enter(data: Dictionary = {}) -> void:
		log.append("enter %s" % data.get("direction", Vector2i.ZERO))

	func exit() -> void:
		log.append("exit")


var _source: FakeSource
var _machine: StateMachine
var _idle: RecordingState
var _move: RecordingState
var _attack: RecordingState


func before_test() -> void:
	_source = auto_free(FakeSource.new())
	_machine = auto_free(StateMachine.new())
	_idle = _add_state("Idle", {&"move": &"Move", &"attack": &"Attack"})
	_move = _add_state("Move", {&"stop": &"Idle"})
	_attack = _add_state("Attack", {})
	_machine.input = _source
	_machine.initial_state = _idle
	add_child(_source)
	add_child(_machine)


func _add_state(state_name: String, transitions: Dictionary) -> RecordingState:
	var state := RecordingState.new()
	state.name = state_name
	state.transitions.assign(transitions)
	_machine.add_child(state)
	return state


func test_starts_in_initial_state() -> void:
	assert_str(_machine.state_name).is_equal("Idle")
	assert_array(_idle.log).contains_exactly(["enter (0, 0)"])


func test_transition_by_table_passes_direction() -> void:
	_source.emit_intent(Intent.new(Intent.MOVE, Vector2i.RIGHT))
	assert_str(_machine.state_name).is_equal("Move")
	assert_array(_idle.log).contains_exactly(["enter (0, 0)", "exit"])
	assert_array(_move.log).contains_exactly(["enter (1, 0)"])


func test_unknown_intent_is_ignored() -> void:
	_source.emit_intent(Intent.new(Intent.DASH))
	assert_str(_machine.state_name).is_equal("Idle")


func test_custom_handler_wins_over_table() -> void:
	var handled: Array[Intent] = []
	_idle.handle(Intent.MOVE, func(intent: Intent) -> void: handled.append(intent))
	_source.emit_intent(Intent.new(Intent.MOVE, Vector2i.UP))
	assert_str(_machine.state_name).is_equal("Idle")
	assert_int(handled.size()).is_equal(1)


func test_can_enter_blocks_transition() -> void:
	_attack.allowed = false
	_source.emit_intent(Intent.new(Intent.ATTACK))
	assert_str(_machine.state_name).is_equal("Idle")


func test_state_changed_signal() -> void:
	var changes: Array[String] = []
	_machine.state_changed.connect(func(from: StringName, to: StringName) -> void: changes.append("%s>%s" % [from, to]))
	_source.emit_intent(Intent.new(Intent.MOVE, Vector2i.LEFT))
	_source.emit_intent(Intent.new(Intent.STOP))
	assert_array(changes).contains_exactly(["Idle>Move", "Move>Idle"])


func test_resume_continues_held_direction() -> void:
	_source.emit_intent(Intent.new(Intent.MOVE, Vector2i.DOWN))
	_machine.transition_to(&"Attack")
	_machine.resume()
	assert_str(_machine.state_name).is_equal("Move")
	assert_str(_move.log.back()).is_equal("enter (0, 1)")


func test_resume_goes_idle_when_nothing_held() -> void:
	_machine.transition_to(&"Attack")
	_machine.resume()
	assert_str(_machine.state_name).is_equal("Idle")
