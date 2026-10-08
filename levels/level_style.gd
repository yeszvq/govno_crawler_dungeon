class_name LevelStyle
extends Resource
## Как выглядит уровень: тайлы, мусор на полу, факелы, освещение.
## Лежит в levels/styles/*.tres. Координаты тайлов — (столбец, строка) в листе Dungeon Crawl.

## Варианты пола и стен (берутся случайно, но одинаково на всех машинах).
@export var floor_tiles: Array[Vector2i] = []
@export var wall_tiles: Array[Vector2i] = []
## Мелочь на полу поверх плитки: листья, кровь, кости. Не мешает ходить.
@export var decals: Array[Vector2i] = []
@export_range(0.0, 1.0) var decal_chance := 0.08
## Символ карты → тайл предмета, который загораживает клетку (дерево, статуя).
@export var props: Dictionary[String, Vector2i] = {}
## Шанс повесить факел на стену, под которой пол.
@export_range(0.0, 1.0) var torch_chance := 0.12
## Сцена настенного факела и костра у места отдыха.
@export var torch_scene: PackedScene
@export var campfire_scene: PackedScene
## Общая освещённость: чем темнее, тем заметнее факелы и свет героев.
@export var ambient := Color(0.35, 0.33, 0.4)
