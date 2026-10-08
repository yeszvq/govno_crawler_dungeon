class_name ActorStats
extends Resource
## Общие характеристики всего, что ходит и дерётся: героев и врагов.

@export var display_name := ""
@export var sprite: Texture2D
@export_group("Characteristics")
@export_range(1, 999) var max_health := 20
@export_range(0, 20) var strength := 5
@export_range(0, 20) var dexterity := 5
@export_range(0, 20) var defense := 0
@export_range(0, 20) var armor := 0
@export_group("Combat")
@export_range(0, 20) var weapon_skill := 0
@export_range(1, 20) var damage_die := 4
## Секунд на один шаг (0.25 = 4 клетки в секунду).
@export_range(0.05, 2.0, 0.01) var step_time := 0.25
## Секунд между ударами.
@export_range(0.1, 5.0, 0.05) var attack_cooldown := 0.6
