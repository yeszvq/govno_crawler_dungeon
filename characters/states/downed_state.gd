class_name DownedState
extends State
## Герой упал (здоровье 0). Союзник может поднять его, нажав «взаимодействие»
## рядом. Если за bleed_out_time никто не помог — смерть.

@export var health: HealthComponent
## Включается, пока герой лежит: через него союзник его поднимает.
@export var revive_point: Interactable
@export var bleed_out_time := 15.0
## Сколько здоровья у поднятого героя, в долях от максимума.
@export_range(0.0, 1.0) var revive_health := 0.3

var _bleed_timer := Timer.new()


func _ready() -> void:
	_bleed_timer.one_shot = true
	_bleed_timer.timeout.connect(_on_bled_out)
	add_child(_bleed_timer)
	health.depleted.connect(_on_health_depleted)
	revive_point.interacted.connect(_on_revived)
	revive_point.enabled = false


func enter(_data: Dictionary = {}) -> void:
	revive_point.enabled = true
	_bleed_timer.start(bleed_out_time)


func exit() -> void:
	revive_point.enabled = false
	_bleed_timer.stop()


func _on_health_depleted(_source: Node) -> void:
	machine.transition_to(name)


func _on_revived(_by: Actor) -> void:
	health.heal(ceili(health.max_health * revive_health))
	machine.transition_to(&"Idle")


func _on_bled_out() -> void:
	machine.transition_to(&"Dead")
