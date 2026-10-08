class_name AttackComponent
extends Node
## Удар ближнего боя в соседнюю клетку. Работает на хосте.
## Попадание и урон считает CombatRules.

signal hit_landed(target: Actor, damage: int)
signal missed(target: Actor)

@export var actor: Actor
## Бонус к попаданию от навыка (выставляет SkillsComponent).
var skill_bonus := 0

var _rng := RandomNumberGenerator.new()


func strike(cell: Vector2i) -> void:
	var target := Grid.occupant_at(cell) as Actor
	var is_valid_target := target != null and target.faction != actor.faction and not target.health.is_depleted
	if not is_valid_target:
		return
	if not CombatRules.roll_hit(actor.stats, target.stats, _rng, skill_bonus):
		missed.emit(target)
		return
	var damage := CombatRules.roll_damage(actor.stats, target.stats, _rng)
	target.health.take_damage(damage, actor)
	hit_landed.emit(target, damage)
	Events.damage_dealt.emit(actor, target, damage)
