extends PanelContainer
## Инвентарь своего героя. Своего героя узнаём из Events.party_slot_assigned.

@export var heroes: Array[Hero] = []
@export var item_list: ItemList

var _hero: Hero


func _ready() -> void:
	Events.party_slot_assigned.connect(_on_party_slot_assigned)


func _on_party_slot_assigned(slot: int, peer_id: int) -> void:
	if peer_id != multiplayer.get_unique_id():
		return
	_hero = heroes[slot]
	if not _hero.inventory.changed.is_connected(_on_inventory_changed):
		_hero.inventory.changed.connect(_on_inventory_changed)
	_on_inventory_changed(_hero.inventory.items)


func _on_inventory_changed(items: Array[ItemDefinition]) -> void:
	item_list.clear()
	for item in items:
		item_list.add_item(item.display_name, item.icon)
