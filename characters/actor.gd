class_name Actor
extends CharacterBody2D
## Всё, что ходит и дерётся: герои и враги. Тело с коллизией, движется свободно.
## Сам ничего не решает: решения принимает StateMachine,
## умения живут в компонентах (дочерних узлах).

@export var stats: ActorStats
## Свои не бьют своих: «heroes» или «monsters».
@export var faction := &"heroes"
@export var sprite: Sprite2D
@export var state_machine: StateMachine
@export var health: HealthComponent
@export var movement: MovementComponent


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	apply_stats()


## Разложить характеристики по компонентам. Зовётся при смене класса/вида.
func apply_stats() -> void:
	sprite.texture = stats.sprite
	health.max_health = stats.max_health
	health.reset()
	movement.speed = stats.move_speed
