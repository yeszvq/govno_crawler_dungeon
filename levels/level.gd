class_name Level
extends Node2D
## Базовая сцена уровня. Уровни по очереди ставятся в Main/LevelContainer,
## герои при этом остаются в Main и просто переставляются на spawn_cells.
##
## Карта задаётся текстом (layout), где каждый символ — клетка:
##     #  стена          .  пол
##     P  точка появления героя (по порядку: слоты 0..3)
##     r  крыса          c  сундук (создаёт только хост)
##     >  спуск глубже   <  подъём в лагерь
##     z  место отдыха (костёр)
##     прочие символы из style.props — загораживающий декор (деревья, статуи)
## Что делать с символом, решает словарь _legend, а не цепочка if.
## Одинаковый текст и seed дают одинаковую карту и декор на всех машинах.

## Координаты тайлов в листе Dungeon Crawl (assets/dungeon_crawl/tileset.tres),
## в клетках по 32 пикселя: (столбец, строка).
const TILE_STAIRS_DOWN := Vector2i(41, 15)
const TILE_STAIRS_UP := Vector2i(42, 15)
const SOURCE_ID := 0

const RAT := "res://data/enemies/rat.tres"
const ENEMY_SCENE := "res://characters/enemies/enemy.tscn"
const CHEST_SCENE := "res://items/chest.tscn"

@export var id: StringName
@export_multiline var layout := ""
@export var style: LevelStyle
## Нижний слой: пол и стены.
@export var tiles: TileMapLayer
## Верхний слой: то, что лежит или стоит на полу. У этих тайлов прозрачный фон.
@export var decor: TileMapLayer
## Сюда спаунер кладёт врагов и предметы.
@export var entities: Node2D
@export var spawner: MultiplayerSpawner
## Общее затемнение уровня (свет факелов и героев пробивается сквозь него).
@export var darkness: CanvasModulate
## Частицы на всю карту: светлячки в лагере, пыль в подземелье.
@export var ambience: CPUParticles2D

## Заполняет LevelLoader до добавления в дерево.
var depth := 0
var level_seed := 0

var spawn_cells: Array[Vector2i] = []
var _walkable: Dictionary[Vector2i, bool] = {}
var _walls: Array[Vector2i] = []
var _legend: Dictionary[String, Callable] = {}
## Декор берёт случайность только отсюда, чтобы у всех вышло одинаково.
var _rng := RandomNumberGenerator.new()


func _enter_tree() -> void:
	Grid.attach_level(self)


func _exit_tree() -> void:
	Grid.detach_level(self)


func _ready() -> void:
	spawner.spawn_function = _spawn_entity
	_rng.seed = level_seed
	darkness.color = style.ambient
	_legend = {
		"#": _add_wall,
		".": _add_floor,
		"P": _add_spawn,
		"r": _add_enemy.bind(RAT),
		"c": _add_chest,
		">": _add_exit.bind(TILE_STAIRS_DOWN, LevelLoader.DUNGEON),
		"<": _add_exit.bind(TILE_STAIRS_UP, LevelLoader.CAMP),
		"z": _add_rest_point,
	}
	for symbol: String in style.props:
		_legend[symbol] = _add_prop.bind(style.props[symbol])
	var rows := _make_layout().strip_edges().split("\n")
	build(rows)
	var region := Rect2i(0, 0, rows[0].length(), rows.size())
	Grid.bake_navigation(region, _walkable)
	_hang_torches()
	_spread_ambience(region)
	Events.level_loaded.emit(self)


func is_walkable(cell: Vector2i) -> bool:
	return _walkable.has(cell)


## Создать сущность через спаунер (только на хосте; клиенты получат копию).
## Сцена сущности должна иметь метод setup(data: Dictionary).
func spawn_entity(scene_path: String, cell: Vector2i, data: Dictionary = {}) -> void:
	spawner.spawn.call_deferred(data.merged({scene = scene_path, cell = cell}))


func build(rows: PackedStringArray) -> void:
	for y in rows.size():
		for x in rows[y].length():
			_legend.get(rows[y][x], _skip).call(Vector2i(x, y))


## Откуда брать карту. DungeonFloor переопределяет и генерирует её по seed.
func _make_layout() -> String:
	return layout


func _spawn_entity(data: Dictionary) -> Node:
	var entity: Node = load(data.scene).instantiate()
	entity.setup(data)
	return entity


func _paint(cell: Vector2i, tile: Vector2i) -> void:
	tiles.set_cell(cell, SOURCE_ID, tile)


func _place_decor(cell: Vector2i, tile: Vector2i) -> void:
	decor.set_cell(cell, SOURCE_ID, tile)


func _pick(variants: Array[Vector2i]) -> Vector2i:
	return variants[_rng.randi() % variants.size()]


func _add_wall(cell: Vector2i) -> void:
	_paint(cell, _pick(style.wall_tiles))
	_walls.append(cell)


func _add_floor(cell: Vector2i) -> void:
	_paint(cell, _pick(style.floor_tiles))
	_walkable[cell] = true
	if not style.decals.is_empty() and _rng.randf() < style.decal_chance:
		_place_decor(cell, _pick(style.decals))


## Пол без мусора: под лестницами, костром, сундуками.
func _add_clean_floor(cell: Vector2i) -> void:
	_paint(cell, _pick(style.floor_tiles))
	_walkable[cell] = true


func _add_spawn(cell: Vector2i) -> void:
	_add_clean_floor(cell)
	spawn_cells.append(cell)


func _add_enemy(cell: Vector2i, definition: String) -> void:
	_add_floor(cell)
	if multiplayer.is_server():
		spawn_entity(ENEMY_SCENE, cell, {definition = definition})


func _add_chest(cell: Vector2i) -> void:
	_add_clean_floor(cell)
	if multiplayer.is_server():
		spawn_entity(CHEST_SCENE, cell)


## Загораживающий декор: дерево, статуя, фонтан.
func _add_prop(cell: Vector2i, tile: Vector2i) -> void:
	_paint(cell, _pick(style.floor_tiles))
	_place_decor(cell, tile)


func _add_exit(cell: Vector2i, tile: Vector2i, target: StringName) -> void:
	_add_clean_floor(cell)
	_paint(cell, tile)
	_add_point(LevelExit.new(target), cell)


func _add_rest_point(cell: Vector2i) -> void:
	_add_clean_floor(cell)
	var campfire := style.campfire_scene.instantiate()
	campfire.position = Grid.cell_to_world(cell)
	add_child(campfire)
	_add_point(RestPoint.new(), cell)


func _add_point(point: Interactable, cell: Vector2i) -> void:
	point.position = Grid.cell_to_world(cell)
	add_child(point)


## Факелы на стенах, у которых снизу пол (их «лицевая» сторона видна игроку).
func _hang_torches() -> void:
	for cell in _walls:
		if _walkable.has(cell + Vector2i.DOWN) and _rng.randf() < style.torch_chance:
			var torch := style.torch_scene.instantiate()
			torch.position = Grid.cell_to_world(cell)
			add_child(torch)


func _spread_ambience(region: Rect2i) -> void:
	var half_size := Vector2(region.size * Grid.CELL_SIZE) / 2.0
	ambience.position = half_size
	ambience.emission_rect_extents = half_size
	ambience.amount = maxi(8, region.get_area() / 6)


func _skip(_cell: Vector2i) -> void:
	pass
