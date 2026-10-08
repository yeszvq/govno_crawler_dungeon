class_name DashState
extends State
## Рывок: короткий быстрый бросок вперёд, потом перезарядка.

@export var movement: MovementComponent
@export var duration := 0.15
@export var speed_multiplier := 3.5
@export var cooldown := 2.0

var _dash_timer := Timer.new()
var _cooldown_timer := Timer.new()


func _ready() -> void:
	_dash_timer.one_shot = true
	_dash_timer.timeout.connect(_on_dash_finished)
	_cooldown_timer.one_shot = true
	add_child(_dash_timer)
	add_child(_cooldown_timer)


func can_enter() -> bool:
	return _cooldown_timer.is_stopped()


func enter(data: Dictionary = {}) -> void:
	var direction: Vector2 = data.get("direction", Vector2.ZERO)
	movement.speed_multiplier = speed_multiplier
	movement.direction = movement.facing if direction == Vector2.ZERO else direction
	_dash_timer.start(duration)


func exit() -> void:
	movement.direction = Vector2.ZERO
	movement.speed_multiplier = 1.0
	_dash_timer.stop()
	_cooldown_timer.start(cooldown)


func _on_dash_finished() -> void:
	machine.resume()
