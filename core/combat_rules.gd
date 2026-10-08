class_name CombatRules
extends RefCounted
## Формулы боя и опыта в одном месте, чтобы их было легко крутить и тестировать.
## Все броски берут RandomNumberGenerator снаружи: в тестах можно задать seed.

const BASE_DEFENSE := 10


## Попал ли удар: d20 + навык оружия + ловкость/2 против 10 + защита цели.
## skill_bonus — прокачанный навык ближнего боя.
static func roll_hit(attacker: ActorStats, defender: ActorStats, rng: RandomNumberGenerator, skill_bonus := 0) -> bool:
	var attack_roll := rng.randi_range(1, 20) + attacker.weapon_skill + skill_bonus + floori(attacker.dexterity / 2.0)
	return attack_roll >= BASE_DEFENSE + defender.defense


## Урон: кубик оружия + сила/3 − броня, но не меньше 1.
static func roll_damage(attacker: ActorStats, defender: ActorStats, rng: RandomNumberGenerator) -> int:
	var raw := rng.randi_range(1, attacker.damage_die) + floori(attacker.strength / 3.0)
	return maxi(1, raw - defender.armor)


## Сколько сырого опыта нужно, чтобы навык поднялся с level до level + 1.
static func xp_to_next_level(level: int) -> int:
	return 20 * (level + 1) * (level + 1)
