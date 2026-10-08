class_name AttackState
extends State
## Удар в клетку перед собой и пауза на перезарядку, потом обратно
## (идём дальше, если направление всё ещё зажато).

@export var actor: Actor
@export var movement: GridMovementComponent
@export var attack: AttackComponent

var _recover_timer := Timer.new()


func _ready() -> void:
	_recover_timer.one_shot = true
	_recover_timer.timeout.connect(_on_recovered)
	add_child(_recover_timer)


func enter(data: Dictionary = {}) -> void:
	# ИИ присылает направление удара, игрок бьёт туда, куда смотрит.
	var direction: Vector2i = data.get("direction", Vector2i.ZERO)
	movement.facing = movement.facing if direction == Vector2i.ZERO else direction
	attack.strike(movement.facing_cell)
	_recover_timer.start(actor.stats.attack_cooldown)


func exit() -> void:
	_recover_timer.stop()


func _on_recovered() -> void:
	machine.resume()
