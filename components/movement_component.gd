class_name MovementComponent
extends Node
## Свободное передвижение тела (CharacterBody2D) в любом направлении.
##
## Считает только хост: пока direction не ноль, тело едет в _physics_process
## (физике нужен каждый кадр), а когда стоит — обработка выключена.
## Клиентам уходит synced_position через MultiplayerSynchronizer, его сеттер
## двигает тело и шлёт moved, так что у всех одни и те же сигналы.

signal moved(world_position: Vector2)
signal facing_changed(facing: Vector2)

@export var body: CharacterBody2D
## Пикселей в секунду. Выставляет Actor из характеристик.
@export var speed := 110.0

## Во сколько раз быстрее обычного (рывок).
var speed_multiplier := 1.0

## Куда едем (единичный вектор) или ноль.
var direction := Vector2.ZERO:
	set(value):
		direction = value
		set_physics_process(value != Vector2.ZERO)
		if value != Vector2.ZERO:
			facing = value

## Куда смотрит персонаж: последнее направление движения или удара.
var facing := Vector2.DOWN:
	set(value):
		facing = value
		facing_changed.emit(value)

var synced_position := Vector2.ZERO:
	set(value):
		synced_position = value
		body.position = value
		moved.emit(value)

## Клетка, в которой стоит тело (для поиска пути).
var cell: Vector2i:
	get: return Grid.world_to_cell(body.position)


func _ready() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	body.velocity = direction * speed * speed_multiplier
	body.move_and_slide()
	synced_position = body.position


## Поставить в точку (появление на уровне, респаун).
func place(world_position: Vector2) -> void:
	synced_position = world_position
