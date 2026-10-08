@abstract
class_name State
extends Node
## Одно состояние персонажа (Idle, Move, Attack...).
##
## Переходы задаются данными, а не цепочками if: в инспекторе у состояния есть
## таблица transitions «вид намерения → состояние», например у Idle:
##     move → Move, attack → Attack, interact → Interact, dash → Dash
## Если состоянию нужно особое поведение, оно регистрирует обработчик:
##     handle(Intent.MOVE, _on_move)
## Обработчик важнее таблицы. Намерения, которых нет ни там ни там, игнорируются.

## Вид намерения → имя состояния, куда переходить.
@export var transitions: Dictionary[StringName, StringName] = {}

## Заполняется стейт-машиной.
var machine: StateMachine

var _handlers: Dictionary[StringName, Callable] = {}


## Подписать обработчик func(intent: Intent) на вид намерения.
func handle(kind: StringName, handler: Callable) -> void:
	_handlers[kind] = handler


func handle_intent(intent: Intent) -> void:
	_handlers.get(intent.kind, _transition_by_table).call(intent)


## Можно ли сейчас войти в это состояние (например, рывок на перезарядке).
func can_enter() -> bool:
	return true


## Вход в состояние. data — что передал предыдущий (например, направление).
func enter(_data: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass


func _transition_by_table(intent: Intent) -> void:
	machine.try_transition(transitions.get(intent.kind, &""), {direction = intent.direction})
