class_name EnemyDeathState
extends State
## Враг умер: роняет лут и исчезает. Удаление на хосте само уходит клиентам
## через MultiplayerSpawner уровня.

@export var enemy: Enemy
@export var health: HealthComponent
@export var corpse_time := 0.4


func _ready() -> void:
	health.depleted.connect(_on_health_depleted)


func enter(_data: Dictionary = {}) -> void:
	enemy.collision_layer = 0
	enemy.drop_loot()
	get_tree().create_timer(corpse_time).timeout.connect(enemy.queue_free)


func _on_health_depleted(_source: Node) -> void:
	machine.transition_to(name)
