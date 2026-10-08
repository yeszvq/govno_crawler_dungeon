class_name Actor
extends Node2D
## Всё, что ходит по сетке и дерётся: герои и враги.
## Сам ничего не решает: решения принимает StateMachine,
## умения живут в компонентах (дочерних узлах).

@export var stats: ActorStats
## Свои не бьют своих: «heroes» или «monsters».
@export var faction := &"heroes"
@export var sprite: Sprite2D
@export var state_machine: StateMachine
@export var health: HealthComponent
@export var movement: GridMovementComponent


func _ready() -> void:
	apply_stats()


## Разложить характеристики по компонентам. Зовётся при смене класса/вида.
func apply_stats() -> void:
	sprite.texture = stats.sprite
	health.max_health = stats.max_health
	health.reset()
	movement.step_time = stats.step_time
