extends Node
## Сетка текущего уровня: перевод клеток в пиксели, проходимость и кто где стоит.
## Движение и атаки идут по клеткам, поэтому вместо физики и Area2D
## все спрашивают Grid: «свободна ли клетка», «кто стоит в клетке».
##
## Уровень сам подключается к Grid в _enter_tree (раньше, чем его дети
## успеют встать на клетки) и отключается в _exit_tree.

## Что-то сдвинулось, появилось или исчезло (для подсказок и т.п.).
signal changed

const CELL_SIZE := 32

var level: Level
## Кто стоит в клетке и мешает пройти (герои, враги, NPC).
var _occupants: Dictionary[Vector2i, Node] = {}
## Что лежит на полу и не мешает пройти (предметы, лестницы).
var _floor_interactables: Dictionary[Vector2i, Interactable] = {}


func attach_level(new_level: Level) -> void:
	level = new_level
	_occupants.clear()
	_floor_interactables.clear()
	changed.emit()


func detach_level(old_level: Level) -> void:
	if level == old_level:
		attach_level(null)


func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell * CELL_SIZE) + Vector2.ONE * (CELL_SIZE / 2.0)


func world_to_cell(world_position: Vector2) -> Vector2i:
	return Vector2i((world_position / CELL_SIZE).floor())


func is_walkable(cell: Vector2i) -> bool:
	return is_instance_valid(level) and level.is_walkable(cell)


func is_free(cell: Vector2i) -> bool:
	return is_walkable(cell) and not _occupants.has(cell)


func occupant_at(cell: Vector2i) -> Node:
	return _occupants.get(cell)


## Переставить сущность. from == to допустимо (первое размещение).
func move_occupant(entity: Node, from: Vector2i, to: Vector2i) -> void:
	release(entity, from)
	_occupants[to] = entity
	changed.emit()


func release(entity: Node, cell: Vector2i) -> void:
	if _occupants.get(cell) == entity:
		_occupants.erase(cell)
		changed.emit()


func add_floor_interactable(interactable: Interactable, cell: Vector2i) -> void:
	_floor_interactables[cell] = interactable
	changed.emit()


func remove_floor_interactable(interactable: Interactable, cell: Vector2i) -> void:
	if _floor_interactables.get(cell) == interactable:
		_floor_interactables.erase(cell)
		changed.emit()


## С чем можно взаимодействовать в клетке: сначала тот, кто там стоит
## (его дочерний узел Interactable), потом то, что лежит на полу.
func interactable_at(cell: Vector2i) -> Interactable:
	var occupant := occupant_at(cell)
	var on_occupant: Interactable = occupant.get_node_or_null(^"Interactable") if occupant else null
	return on_occupant if on_occupant else _floor_interactables.get(cell)
