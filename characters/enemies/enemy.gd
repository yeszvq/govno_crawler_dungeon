class_name Enemy
extends Actor
## Враг. Создаётся хостом через MultiplayerSpawner уровня (Level.spawn_entity),
## клиенты получают копию автоматически.

const PICKUP_SCENE := "res://items/pickup.tscn"


## Вызывается спаунером до добавления в дерево. data: definition, cell.
func setup(data: Dictionary) -> void:
	stats = load(data.definition)
	movement.place(Grid.cell_to_world(data.cell))


func drop_loot() -> void:
	var definition := stats as EnemyDefinition
	if definition.loot.is_empty():
		return
	var item: ItemDefinition = definition.loot.pick_random()
	Grid.level.spawn_entity(PICKUP_SCENE, movement.cell, {item = item.resource_path, position = global_position})
