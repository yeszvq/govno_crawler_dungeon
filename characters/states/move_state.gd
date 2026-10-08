class_name MoveState
extends State
## Идёт в зажатом направлении. Смена направления не выходит из состояния,
## STOP и прочее — по таблице transitions.

@export var movement: MovementComponent


func _ready() -> void:
	handle(Intent.MOVE, _on_move)


func enter(data: Dictionary = {}) -> void:
	movement.direction = data.get("direction", movement.facing)


func exit() -> void:
	movement.direction = Vector2.ZERO


func _on_move(intent: Intent) -> void:
	movement.direction = intent.direction
