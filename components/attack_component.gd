class_name AttackComponent
extends Node
## Удар ближнего боя в любую сторону. Зона удара — круг перед персонажем,
## задевает всех чужих в нём. Попадание и урон считает CombatRules на хосте,
## а что показать (взмах, искры, «промах») рассылается всем по RPC.

signal hit_landed(target: Actor, damage: int)
signal missed(target: Actor)

@export var actor: Actor
## На сколько пикселей вперёд вынесен центр зоны удара.
@export var reach := 18.0
## Радиус зоны удара.
@export var radius := 16.0
## Цвет взмаха.
@export var swing_color := Color(1, 1, 1, 0.85)

## Бонус к попаданию от навыка (выставляет SkillsComponent).
var skill_bonus := 0

var _rng := RandomNumberGenerator.new()
var _zone := CircleShape2D.new()


## Ударить в сторону aim (единичный вектор). Только на хосте.
func strike(aim: Vector2) -> void:
	_show_swing.rpc(aim)
	# Пространство физики безопасно опрашивать в физическом кадре.
	await get_tree().physics_frame
	for target in targets_in_zone(aim):
		_resolve(target)


## Кого задевает удар в сторону aim.
func targets_in_zone(aim: Vector2) -> Array[Actor]:
	_zone.radius = radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _zone
	query.transform = Transform2D(0.0, actor.global_position + aim * reach)
	query.collision_mask = PhysicsLayers.ACTORS
	query.exclude = [actor.get_rid()]
	var targets: Array[Actor] = []
	for hit in actor.get_world_2d().direct_space_state.intersect_shape(query, 8):
		var target := hit.collider as Actor
		if target and target.faction != actor.faction and not target.health.is_depleted:
			targets.append(target)
	return targets


func _resolve(target: Actor) -> void:
	if not CombatRules.roll_hit(actor.stats, target.stats, _rng, skill_bonus):
		missed.emit(target)
		_show_impact.rpc(target.global_position, false)
		return
	var damage := CombatRules.roll_damage(actor.stats, target.stats, _rng)
	target.health.take_damage(damage, actor)
	hit_landed.emit(target, damage)
	Events.damage_dealt.emit(actor, target, damage)
	_show_impact.rpc(target.global_position, true)


@rpc("authority", "call_local", "unreliable")
func _show_swing(aim: Vector2) -> void:
	Events.swing_shown.emit(actor.global_position + aim * reach * 0.5, aim, swing_color)


@rpc("authority", "call_local", "unreliable")
func _show_impact(world_position: Vector2, is_hit: bool) -> void:
	Events.impact_shown.emit(world_position, is_hit)
