class_name AttackState
extends State
## Удар в сторону прицела и пауза на перезарядку, потом обратно
## (идём дальше, если направление всё ещё зажато).

@export var actor: Actor
@export var movement: MovementComponent
@export var attack: AttackComponent

var _recover_timer := Timer.new()


func _ready() -> void:
	_recover_timer.one_shot = true
	_recover_timer.timeout.connect(_on_recovered)
	add_child(_recover_timer)


func enter(data: Dictionary = {}) -> void:
	var aim: Vector2 = data.get("direction", Vector2.ZERO)
	movement.facing = movement.facing if aim == Vector2.ZERO else aim
	attack.strike(movement.facing)
	_recover_timer.start(actor.stats.attack_cooldown)


func exit() -> void:
	_recover_timer.stop()


func _on_recovered() -> void:
	machine.resume()
