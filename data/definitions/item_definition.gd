class_name ItemDefinition
extends Resource
## Предмет. Лежит в data/items/*.tres.

enum Kind { MISC, FOOD, WEAPON, ARMOR, POTION }

@export var id: StringName
@export var display_name := ""
@export var icon: Texture2D
@export var kind := Kind.MISC
@export var weight := 1.0
## Для еды: сколько сытости восстанавливает.
@export var satiety := 0
