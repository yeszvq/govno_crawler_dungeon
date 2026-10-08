class_name StateMachine
extends Node
## Центральный узел персонажа: принимает намерения от IntentSource
## и отдаёт их текущему состоянию. Состояния — дочерние узлы State.
##
## Логика (enter/exit, таймеры, урон) работает только на хосте: туда приходят
## намерения всех игроков. Клиенты получают лишь state_name через
## MultiplayerSynchronizer, и сигнал state_changed срабатывает у всех,
## чтобы визуал и интерфейс реагировали одинаково.

signal state_changed(previous: StringName, current: StringName)

@export var input: IntentSource
@export var initial_state: State

## Имя текущего состояния. Синхронизируется по сети.
var state_name: StringName:
	set(value):
		var previous := state_name
		state_name = value
		state_changed.emit(previous, value)

var current: State
var _states: Dictionary[StringName, State] = {}


func _ready() -> void:
	for state: State in get_children().filter(func(node: Node) -> bool: return node is State):
		state.machine = self
		_states[state.name] = state
	input.intent_received.connect(dispatch)
	current = initial_state
	state_name = current.name
	current.enter()


func dispatch(intent: Intent) -> void:
	current.handle_intent(intent)


func transition_to(target: StringName, data: Dictionary = {}) -> void:
	current.exit()
	current = _states[target]
	state_name = target
	current.enter(data)


## Перейти, если такое состояние есть и в него сейчас можно войти.
func try_transition(target: StringName, data: Dictionary = {}) -> bool:
	var state: State = _states.get(target)
	var allowed := state != null and state.can_enter()
	if allowed:
		transition_to(target, data)
	return allowed


## Вернуться к обычному поведению после удара, рывка и т.п.:
## если игрок держит направление, идём дальше, иначе стоим.
func resume() -> void:
	var target := &"Idle" if input.held_direction == Vector2i.ZERO else &"Move"
	transition_to(target, {direction = input.held_direction})


func has_state(target: StringName) -> bool:
	return _states.has(target)


## Есть ли у текущего состояния переход по такому намерению.
## Работает и у клиентов, потому что смотрит на синхронизированный state_name.
func accepts(kind: StringName) -> bool:
	var state: State = _states.get(state_name)
	return state != null and state.transitions.has(kind)
