class_name SkillsComponent
extends Node
## Навыки растут от использования: удар копит «сырой» опыт,
## а в уровни он превращается только когда пати отдохнула (Events.party_rested).

signal leveled_up(skill: StringName, level: int)

const MELEE := &"melee"

## Откуда брать опыт ближнего боя.
@export var attack: AttackComponent

var levels: Dictionary[StringName, int] = {}
var raw_xp: Dictionary[StringName, int] = {}


func _ready() -> void:
	attack.hit_landed.connect(_on_hit_landed)
	Events.party_rested.connect(_on_party_rested)


func level_of(skill: StringName) -> int:
	return levels.get(skill, 0)


func add_xp(skill: StringName, amount: int) -> void:
	raw_xp[skill] = raw_xp.get(skill, 0) + amount


## Переводит накопленный опыт в уровни.
func consolidate() -> void:
	for skill: StringName in raw_xp:
		_consolidate_skill(skill)
	attack.skill_bonus = level_of(MELEE)


func _consolidate_skill(skill: StringName) -> void:
	while raw_xp[skill] >= CombatRules.xp_to_next_level(level_of(skill)):
		raw_xp[skill] -= CombatRules.xp_to_next_level(level_of(skill))
		levels[skill] = level_of(skill) + 1
		leveled_up.emit(skill, levels[skill])


func _on_hit_landed(_target: Actor, _damage: int) -> void:
	add_xp(MELEE, 1)


func _on_party_rested() -> void:
	if multiplayer.is_server():
		consolidate()
