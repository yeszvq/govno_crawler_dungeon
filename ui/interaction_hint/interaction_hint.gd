class_name InteractionHint
extends Node2D
## Подсказка «[E] Поговорить» над тем, с чем свой герой может сейчас взаимодействовать.
## Пересчитывается по событиям: герой сдвинулся или сменил состояние,
## что-то интерактивное появилось/исчезло/выключилось, открылось меню.

const ACTION := &"interact"
const OFFSET := Vector2(0, -26)

@export var heroes: Array[Hero] = []
@export var label: Label

var _hero: Hero
var _menu_open := false
var _key_name := "E"


func _ready() -> void:
	hide()
	var key := InputMap.action_get_events(ACTION).front() as InputEventKey
	if key:
		_key_name = OS.get_keycode_string(key.physical_keycode)
	Events.party_slot_assigned.connect(_on_party_slot_assigned)
	Events.menu_toggled.connect(_on_menu_toggled)
	Events.session_ended.connect(_watch.bind(null))
	Events.interactables_changed.connect(_refresh)


func _on_party_slot_assigned(slot: int, peer_id: int) -> void:
	if peer_id == multiplayer.get_unique_id():
		_watch(heroes[slot])


func _on_menu_toggled(is_open: bool) -> void:
	_menu_open = is_open
	_refresh()


## Следить за своим героем (null — ни за кем).
func _watch(hero: Hero) -> void:
	if _hero:
		_hero.movement.moved.disconnect(_on_hero_moved)
		_hero.state_machine.state_changed.disconnect(_on_state_changed)
	_hero = hero
	if _hero:
		_hero.movement.moved.connect(_on_hero_moved)
		_hero.state_machine.state_changed.connect(_on_state_changed)
	_refresh()


func _on_hero_moved(_position: Vector2) -> void:
	_refresh()


func _on_state_changed(_previous: StringName, _current: StringName) -> void:
	_refresh()


func _refresh() -> void:
	var target := _target()
	visible = target != null
	if target:
		label.text = "[%s] %s" % [_key_name, target.prompt]
		position = target.global_position + OFFSET


## С чем герой может взаимодействовать прямо сейчас, или null.
func _target() -> Interactable:
	var can_interact := _hero != null and not _menu_open and _hero.state_machine.accepts(Intent.INTERACT)
	return _hero.interaction.find_target() if can_interact else null
