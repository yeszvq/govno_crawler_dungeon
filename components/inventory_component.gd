class_name InventoryComponent
extends Node
## Инвентарь. Лут забирает тот, кто поднял.
## По сети уходят пути к .tres предметов (item_paths), объекты собираются на месте.

signal changed(items: Array[ItemDefinition])

var items: Array[ItemDefinition] = []

var item_paths := PackedStringArray():
	set(value):
		item_paths = value
		items.assign(Array(value).map(func(path: String) -> Resource: return load(path)))
		changed.emit(items)


func add(item: ItemDefinition) -> void:
	item_paths = item_paths + PackedStringArray([item.resource_path])


func remove(item: ItemDefinition) -> void:
	var paths := item_paths.duplicate()
	paths.remove_at(paths.find(item.resource_path))
	item_paths = paths


func clear() -> void:
	item_paths = PackedStringArray()
