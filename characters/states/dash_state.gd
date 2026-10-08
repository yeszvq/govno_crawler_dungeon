class_name DashState
extends State
## Рывок: несколько быстрых шагов подряд, потом перезарядка.

@export var movement: GridMovementComponent
@export var cells := 2
@export var step_time := 0.06
@export var cooldown := 2.0

var _steps_left := 0
var _step_timer := Timer.new()
var _cooldown_timer := Timer.new()


func _ready() -> void:
	_step_timer.timeout.connect(_step)
	_cooldown_timer.one_shot = true
	add_child(_step_timer)
	add_child(_cooldown_timer)


func can_enter() -> bool:
	return _cooldown_timer.is_stopped()


func enter(data: Dictionary = {}) -> void:
	var direction: Vector2i = data.get("direction", Vector2i.ZERO)
	movement.facing = movement.facing if direction == Vector2i.ZERO else direction
	_steps_left = cells
	_step_timer.start(step_time)
	_step()


func exit() -> void:
	_step_timer.stop()
	_cooldown_timer.start(cooldown)


func _step() -> void:
	_steps_left -= 1
	var moved := movement.try_step(movement.facing)
	if _steps_left <= 0 or not moved:
		machine.resume()
