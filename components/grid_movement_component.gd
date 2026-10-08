class_name GridMovementComponent
extends Node
## Передвижение по клеткам. cell и facing синхронизируются по сети,
## а сеттер сам двигает картинку, поэтому клиентам ничего считать не нужно.

signal moved(from: Vector2i, to: Vector2i)
signal facing_changed(facing: Vector2i)

## Что двигать на экране. Обычно корень персонажа.
@export var body: Node2D
## Длительность анимации шага, секунд.
@export var step_time := 0.25

var cell := Vector2i.ZERO:
	set(value):
		var from := cell
		cell = value
		Grid.move_occupant(body, from, value)
		_show_move(from, value)
		moved.emit(from, value)

var facing := Vector2i.DOWN:
	set(value):
		facing = value
		facing_changed.emit(value)

## Клетка прямо перед персонажем.
var facing_cell: Vector2i:
	get: return cell + facing

var _tween: Tween


## Повернуться и шагнуть, если клетка свободна. Возвращает, получилось ли.
func try_step(direction: Vector2i) -> bool:
	facing = direction
	var target := cell + direction
	var is_free := Grid.is_free(target)
	if is_free:
		cell = target
	return is_free


## Поставить на клетку (появление на уровне, респаун).
func place(target: Vector2i) -> void:
	cell = target


func _exit_tree() -> void:
	Grid.release(body, cell)


func _show_move(from: Vector2i, to: Vector2i) -> void:
	if _tween:
		_tween.kill()
	var target_position := Grid.cell_to_world(to)
	# Соседняя клетка — плавный шаг, всё остальное (появление, телепорт) — сразу.
	var is_step := (to - from).length_squared() == 1 and body.is_inside_tree()
	if not is_step:
		body.position = target_position
		return
	_tween = body.create_tween()
	_tween.tween_property(body, ^"position", target_position, step_time)
