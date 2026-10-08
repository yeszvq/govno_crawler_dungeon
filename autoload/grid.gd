extends Node
## Карта текущего уровня в клетках по 32 px: перевод клеток в пиксели,
## проходимость и поиск пути для врагов. Передвижение свободное (физика),
## а сетка нужна, чтобы строить уровни и прокладывать маршруты.
##
## Уровень подключается сам: attach_level в _enter_tree, bake_navigation
## после постройки карты, detach_level в _exit_tree.

const CELL_SIZE := 32

var level: Level
var _astar := AStarGrid2D.new()


func attach_level(new_level: Level) -> void:
	level = new_level
	_astar = AStarGrid2D.new()


func detach_level(old_level: Level) -> void:
	if level == old_level:
		attach_level(null)


## Построить карту проходимости для поиска пути. region — границы карты в клетках.
func bake_navigation(region: Rect2i, walkable: Dictionary[Vector2i, bool]) -> void:
	_astar.region = region
	_astar.cell_size = Vector2.ONE * CELL_SIZE
	_astar.offset = Vector2.ONE * (CELL_SIZE / 2.0)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.update()
	_astar.fill_solid_region(region, true)
	for cell in walkable:
		_astar.set_point_solid(cell, false)


func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell * CELL_SIZE) + Vector2.ONE * (CELL_SIZE / 2.0)


func world_to_cell(world_position: Vector2) -> Vector2i:
	return Vector2i((world_position / CELL_SIZE).floor())


func is_walkable(cell: Vector2i) -> bool:
	return is_instance_valid(level) and level.is_walkable(cell)


## Путь между точками мира по центрам клеток. Пустой, если пути нет.
func find_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var start := world_to_cell(from)
	var goal := world_to_cell(to)
	var reachable := is_walkable(start) and is_walkable(goal)
	return _astar.get_point_path(start, goal) if reachable else PackedVector2Array()
