class_name NeedsComponent
extends Node
## Голод и усталость. Убывают от игровых минут (Events.game_minute_passed),
## а не в _process. Считает хост, клиенты получают значения по сети.

signal changed(satiety: int, energy: int)
## Потребность упала до нуля (&"satiety" или &"energy").
signal exhausted(need: StringName)

const MAX_VALUE := 100

## Сколько игровых минут на одно очко сытости и бодрости.
@export var minutes_per_satiety := 15
@export var minutes_per_energy := 10

var satiety := MAX_VALUE:
	set(value):
		satiety = clampi(value, 0, MAX_VALUE)
		changed.emit(satiety, energy)

var energy := MAX_VALUE:
	set(value):
		energy = clampi(value, 0, MAX_VALUE)
		changed.emit(satiety, energy)


func _ready() -> void:
	Events.game_minute_passed.connect(_on_game_minute_passed)
	Events.party_rested.connect(_on_party_rested)


func eat(item: ItemDefinition) -> void:
	satiety += item.satiety


func reset() -> void:
	satiety = MAX_VALUE
	energy = MAX_VALUE


func _on_game_minute_passed(total: int) -> void:
	if not multiplayer.is_server():
		return
	satiety -= int(total % minutes_per_satiety == 0)
	energy -= int(total % minutes_per_energy == 0)
	_report_exhausted(&"satiety", satiety)
	_report_exhausted(&"energy", energy)


func _on_party_rested() -> void:
	energy = MAX_VALUE


func _report_exhausted(need: StringName, value: int) -> void:
	if value == 0:
		exhausted.emit(need)
