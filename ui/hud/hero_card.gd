class_name HeroCard
extends PanelContainer
## Карточка героя в HUD: портрет, имя и полоски здоровья, сытости и бодрости.
## Обновляется по сигналам компонентов героя, без опроса каждый кадр.

const BAR_COLORS: Dictionary[StringName, Color] = {
	&"health": Color(0.78, 0.16, 0.16),
	&"satiety": Color(0.85, 0.6, 0.2),
	&"energy": Color(0.3, 0.55, 0.9),
}
## Подпись состояния под именем.
const STATE_NAMES: Dictionary[StringName, String] = {
	&"Downed": "упал!",
	&"Dead": "погиб",
}

var hero: Hero:
	set(value):
		hero = value
		hero.health.changed.connect(_refresh.unbind(2))
		hero.needs.changed.connect(_refresh.unbind(2))
		hero.state_machine.state_changed.connect(_refresh.unbind(2))
		Events.party_slot_assigned.connect(_refresh.unbind(2))
		_refresh()

var _portrait := TextureRect.new()
var _name := Label.new()
var _bars: Dictionary[StringName, ProgressBar] = {}


func _init() -> void:
	custom_minimum_size = Vector2(250, 0)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 8)
	add_child(row)
	_portrait.custom_minimum_size = Vector2(48, 48)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(_portrait)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override(&"separation", 2)
	row.add_child(column)
	column.add_child(_name)
	for bar_name: StringName in BAR_COLORS:
		_bars[bar_name] = _make_bar(BAR_COLORS[bar_name])
		column.add_child(_bars[bar_name])


func _make_bar(color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 7)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(2)
	bar.add_theme_stylebox_override(&"fill", fill)
	return bar


func _refresh() -> void:
	visible = hero.owner_peer_id != PartyService.FREE
	_portrait.texture = hero.stats.sprite
	var state_text: String = STATE_NAMES.get(hero.state_machine.state_name, "")
	_name.text = ("%s  %s" % [hero.stats.display_name, state_text]).strip_edges()
	_set_bar(&"health", hero.health.current, hero.health.max_health)
	_set_bar(&"satiety", hero.needs.satiety, NeedsComponent.MAX_VALUE)
	_set_bar(&"energy", hero.needs.energy, NeedsComponent.MAX_VALUE)


func _set_bar(bar_name: StringName, value: int, maximum: int) -> void:
	_bars[bar_name].max_value = maximum
	_bars[bar_name].value = value
