class_name HealthComponent
extends Node
## Здоровье. Урон и лечение меняются только на хосте, current уходит
## клиентам через MultiplayerSynchronizer, и changed срабатывает везде.

signal changed(current: int, maximum: int)
signal damaged(amount: int, source: Node)
## Здоровье кончилось (только на хосте, там где нанесли урон).
signal depleted(source: Node)

@export var max_health := 20:
	set(value):
		max_health = value
		changed.emit(current, max_health)

var current := 20:
	set(value):
		current = clampi(value, 0, max_health)
		changed.emit(current, max_health)

var is_depleted: bool:
	get: return current == 0


func reset() -> void:
	current = max_health


func take_damage(amount: int, source: Node = null) -> void:
	if is_depleted:
		return
	current -= amount
	damaged.emit(amount, source)
	if is_depleted:
		depleted.emit(source)


func heal(amount: int) -> void:
	current += amount
