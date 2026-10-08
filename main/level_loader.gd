class_name LevelLoader
extends Node
## Смена уровней. Уровень создаёт хост через MultiplayerSpawner, поэтому
## он сам появляется у всех клиентов, включая подключившихся позже.
## Герои не пересоздаются: после загрузки хост переставляет их на точки появления.

const CAMP := &"camp"
const DUNGEON := &"dungeon"

@export var spawner: MultiplayerSpawner
@export var container: Node
@export var party: PartyService
## id уровня → сцена.
@export var levels: Dictionary[StringName, PackedScene] = {}

var current: Level
## Глубина текущего этажа (0 — лагерь).
var depth := 0


func _ready() -> void:
	spawner.spawn_function = _spawn_level
	Events.session_started.connect(_on_session_started)
	Events.session_ended.connect(_clear)
	Events.level_change_requested.connect(_on_level_change_requested)
	Events.level_loaded.connect(_on_level_loaded)
	Events.party_slot_assigned.connect(_on_party_slot_assigned)
	Events.hero_died.connect(_on_hero_died)


## Только на хосте.
func change_level(id: StringName) -> void:
	_clear()
	depth = 0 if id == CAMP else depth + 1
	spawner.spawn({id = id, depth = depth, seed = randi()})


func _spawn_level(data: Dictionary) -> Node:
	var level: Level = levels[StringName(data.id)].instantiate()
	level.depth = data.depth
	level.level_seed = data.seed
	return level


func _clear() -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	current = null


func _on_session_started(is_host: bool) -> void:
	if is_host:
		change_level(CAMP)


func _on_level_change_requested(id: StringName) -> void:
	if multiplayer.is_server():
		change_level.call_deferred(id)


func _on_level_loaded(level: Level) -> void:
	current = level
	if not multiplayer.is_server():
		return
	for hero in party.active_heroes():
		hero.enter_level(level.spawn_cells[hero.slot])


func _on_party_slot_assigned(slot: int, peer_id: int) -> void:
	if multiplayer.is_server() and current and peer_id != PartyService.FREE:
		party.heroes[slot].enter_level(current.spawn_cells[slot])


## Все погибли — забег окончен, все возвращаются в лагерь.
func _on_hero_died(_hero: Hero) -> void:
	var everyone_dead := party.active_heroes().all(
		func(hero: Hero) -> bool: return hero.state_machine.state_name == &"Dead")
	if multiplayer.is_server() and everyone_dead:
		change_level.call_deferred(CAMP)
