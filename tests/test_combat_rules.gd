extends GdUnitTestSuite


func _stats(strength: int, dexterity: int, armor: int, defense: int, die: int) -> ActorStats:
	var stats := ActorStats.new()
	stats.strength = strength
	stats.dexterity = dexterity
	stats.armor = armor
	stats.defense = defense
	stats.damage_die = die
	return stats


func test_damage_is_at_least_one() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var weak := _stats(0, 0, 0, 0, 1)
	var tank := _stats(0, 0, 20, 0, 1)
	for i in 50:
		assert_int(CombatRules.roll_damage(weak, tank, rng)).is_equal(1)


func test_damage_range() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2
	var attacker := _stats(6, 0, 0, 0, 8) # +2 от силы
	var target := _stats(0, 0, 1, 0, 1)
	for i in 100:
		assert_int(CombatRules.roll_damage(attacker, target, rng)).is_between(2, 9)


func test_skill_bonus_makes_hits_certain() -> void:
	var rng := RandomNumberGenerator.new()
	var attacker := _stats(0, 0, 0, 0, 4)
	var target := _stats(0, 0, 0, 5, 4)
	for i in 50:
		assert_bool(CombatRules.roll_hit(attacker, target, rng, 14)).is_true()


func test_xp_curve() -> void:
	assert_int(CombatRules.xp_to_next_level(0)).is_equal(20)
	assert_int(CombatRules.xp_to_next_level(1)).is_equal(80)
	assert_int(CombatRules.xp_to_next_level(2)).is_equal(180)
