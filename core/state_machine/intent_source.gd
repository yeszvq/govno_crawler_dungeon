@abstract
class_name IntentSource
extends Node
## Источник намерений для стейт-машины: клавиатура игрока или ИИ врага.
## Стейт-машина подписывается на intent_received и больше ничего не знает
## об устройстве ввода.

signal intent_received(intent: Intent)

## Какое направление сейчас зажато. Нужно, чтобы после удара или рывка
## персонаж продолжил идти, если игрок так и держит клавишу.
var held_direction := Vector2.ZERO


func emit_intent(intent: Intent) -> void:
	held_direction = _held_update.get(intent.kind, _keep_held).call(intent)
	intent_received.emit(intent)


var _held_update: Dictionary[StringName, Callable] = {
	Intent.MOVE: func(intent: Intent) -> Vector2: return intent.direction,
	Intent.STOP: func(_intent: Intent) -> Vector2: return Vector2.ZERO,
}


func _keep_held(_intent: Intent) -> Vector2:
	return held_direction
