class_name MoveState
extends State
## Идёт в зажатом направлении: шаг сразу и дальше по таймеру шага.
## Смена направления не выходит из состояния, STOP и прочее — по таблице.

@export var actor: Actor
@export var movement: GridMovementComponent

var _direction := Vector2i.ZERO
var _step_timer := Timer.new()


func _ready() -> void:
	_step_timer.timeout.connect(_step)
	add_child(_step_timer)
	handle(Intent.MOVE, _on_move)


func enter(data: Dictionary = {}) -> void:
	_direction = data.get("direction", movement.facing)
	_step_timer.wait_time = actor.stats.step_time
	_step()
	_step_timer.start()


func exit() -> void:
	_step_timer.stop()


func _on_move(intent: Intent) -> void:
	_direction = intent.direction
	movement.facing = intent.direction


func _step() -> void:
	movement.try_step(_direction)
