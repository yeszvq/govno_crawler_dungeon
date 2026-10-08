class_name PartyService
extends Node
## Кто каким героем играет. Хост раздаёт слоты 0..3 по мере подключения
## и рассылает всем таблицу слотов; каждая машина выставляет героям владельцев
## и эмитит Events.party_slot_assigned.

const FREE := 0

@export var heroes: Array[Hero] = []

## slot → peer_id (0 — свободно). Ведёт хост.
var _slots := PackedInt32Array([FREE, FREE, FREE, FREE])


func _ready() -> void:
	Events.peer_joined.connect(_on_peer_joined)
	Events.peer_left.connect(_on_peer_left)
	Events.session_ended.connect(_on_session_ended)


func active_heroes() -> Array[Hero]:
	var active: Array[Hero] = []
	active.assign(heroes.filter(func(hero: Hero) -> bool: return hero.owner_peer_id != FREE))
	return active


func hero_of(peer_id: int) -> Hero:
	var slot := _slots.find(peer_id)
	return heroes[slot] if slot >= 0 else null


func _on_peer_joined(peer_id: int) -> void:
	var slot := _slots.find(FREE)
	if not multiplayer.is_server() or slot == -1:
		return
	_slots[slot] = peer_id
	_apply_table.rpc(_slots)


func _on_peer_left(peer_id: int) -> void:
	var slot := _slots.find(peer_id)
	if not multiplayer.is_server() or slot == -1:
		return
	_slots[slot] = FREE
	_apply_table.rpc(_slots)


func _on_session_ended() -> void:
	_apply_table(PackedInt32Array([FREE, FREE, FREE, FREE]))


@rpc("authority", "call_local", "reliable")
func _apply_table(slots: PackedInt32Array) -> void:
	_slots = slots
	for slot in heroes.size():
		_assign(slot, slots[slot])


func _assign(slot: int, peer_id: int) -> void:
	var hero := heroes[slot]
	if hero.owner_peer_id == peer_id:
		return
	hero.owner_peer_id = peer_id
	Events.party_slot_assigned.emit(slot, peer_id)
