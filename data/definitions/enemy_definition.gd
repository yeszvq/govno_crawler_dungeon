class_name EnemyDefinition
extends ActorStats
## Вид врага. Лежит в data/enemies/*.tres.

## С какого расстояния (в клетках) враг замечает героя.
@export_range(1, 30) var aggro_range := 6
## Как часто ИИ «думает», секунд.
@export_range(0.1, 3.0, 0.05) var think_interval := 0.5
## Что может выпасть при смерти.
@export var loot: Array[ItemDefinition] = []
