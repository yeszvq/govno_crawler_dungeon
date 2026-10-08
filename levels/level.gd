class_name Level
extends Node2D
## Базовая сцена уровня. Уровни по очереди ставятся в Main/LevelContainer,
## герои при этом остаются в Main и просто переставляются на spawn_cells.
##
## Карта задаётся текстом (layout), где каждый символ — клетка:
##     #  стена          .  пол
##     P  точка появления героя (по порядку: слоты 0..3)
##     r  крыса (создаёт только хост)
##     >  спуск глубже   <  подъём в лагерь
##     z  место отдыха (костёр)
## Что делать с символом, решает словарь _legend, а не цепочка if.
## Одинаковый текст/seed дают одинаковую карту на всех машинах.

## Атлас тайлов в assets/placeholder/tileset.tres.
const TILE_FLOOR := Vector2i(0, 0)
const TILE_WALL := Vector2i(1, 0)
const TILE_STAIRS_DOWN := Vector2i(2, 0)
const TILE_STAIRS_UP := Vector2i(3, 0)
const TILE_CAMPFIRE := Vector2i(4, 0)

const RAT := "res://data/enemies/rat.tres"
const ENEMY_SCENE := "res://characters/enemies/enemy.tscn"

@export var id: StringName
@export_multiline var layout := ""
@export var tiles: TileMapLayer
## Сюда спаунер кладёт врагов и предметы.
@export var entities: Node2D
@export var spawner: MultiplayerSpawner

## Заполняет LevelLoader до добавления в дерево.
var depth := 0
var level_seed := 0

var spawn_cells: Array[Vector2i] = []
var _walkable: Dictionary[Vector2i, bool] = {}
var _legend: Dictionary[String, Callable] = {}


func _enter_tree() -> void:
	Grid.attach_level(self)


func _exit_tree() -> void:
	Grid.detach_level(self)


func _ready() -> void:
	spawner.spawn_function = _spawn_entity
	_legend = {
		"#": _paint.bind(TILE_WALL),
		".": _add_floor,
		"P": _add_spawn,
		"r": _add_enemy.bind(RAT),
		">": _add_exit.bind(TILE_STAIRS_DOWN, LevelLoader.DUNGEON),
		"<": _add_exit.bind(TILE_STAIRS_UP, LevelLoader.CAMP),
		"z": _add_rest_point,
	}
	build(_make_layout())
	Events.level_loaded.emit(self)


func is_walkable(cell: Vector2i) -> bool:
	return _walkable.has(cell)


## Создать сущность через спаунер (только на хосте; клиенты получат копию).
## Сцена сущности должна иметь метод setup(data: Dictionary).
func spawn_entity(scene_path: String, cell: Vector2i, data: Dictionary = {}) -> void:
	spawner.spawn.call_deferred(data.merged({scene = scene_path, cell = cell}))


func build(text: String) -> void:
	var rows := text.strip_edges().split("\n")
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
	tiles.set_cell(cell, 0, tile)


func _add_floor(cell: Vector2i) -> void:
	_paint(cell, TILE_FLOOR)
	_walkable[cell] = true


func _add_spawn(cell: Vector2i) -> void:
	_add_floor(cell)
	spawn_cells.append(cell)


func _add_enemy(cell: Vector2i, definition: String) -> void:
	_add_floor(cell)
	if multiplayer.is_server():
		spawn_entity(ENEMY_SCENE, cell, {definition = definition})


func _add_exit(cell: Vector2i, tile: Vector2i, target: StringName) -> void:
	_add_floor(cell)
	_paint(cell, tile)
	_add_floor_point(LevelExit.new(target), cell)


func _add_rest_point(cell: Vector2i) -> void:
	_add_floor(cell)
	_paint(cell, TILE_CAMPFIRE)
	_add_floor_point(RestPoint.new(), cell)


func _add_floor_point(point: Interactable, cell: Vector2i) -> void:
	add_child(point)
	Grid.add_floor_interactable(point, cell)


func _skip(_cell: Vector2i) -> void:
	pass
