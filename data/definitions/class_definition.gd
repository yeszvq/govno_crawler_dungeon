class_name ClassDefinition
extends ActorStats
## Класс героя (воин, плут, жрец, маг). Лежит в data/classes/*.tres.

@export_multiline var description := ""
## Стартовые предметы в инвентаре.
@export var starting_items: Array[ItemDefinition] = []
