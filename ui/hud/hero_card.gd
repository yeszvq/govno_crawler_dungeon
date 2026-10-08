class_name HeroCard
extends Label
## Карточка героя в HUD: имя, здоровье, сытость, бодрость.
## Обновляется по сигналам компонентов героя, без опроса каждый кадр.

var hero: Hero:
	set(value):
		hero = value
		hero.health.changed.connect(_refresh.unbind(2))
		hero.needs.changed.connect(_refresh.unbind(2))
		hero.state_machine.state_changed.connect(_refresh.unbind(2))
		Events.party_slot_assigned.connect(_refresh.unbind(2))
		_refresh()


func _refresh() -> void:
	visible = hero.owner_peer_id != PartyService.FREE
	text = "%s  ♥ %d/%d  🍖 %d  ⚡ %d  %s" % [
		hero.stats.display_name,
		hero.health.current, hero.health.max_health,
		hero.needs.satiety, hero.needs.energy,
		hero.state_machine.state_name,
	]
