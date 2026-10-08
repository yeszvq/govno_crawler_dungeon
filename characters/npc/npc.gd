class_name Npc
extends Node2D
## Мирный житель. Стоит в своей клетке (её берём из позиции в сцене уровня),
## с ним можно поговорить через Interactable + DialogueTrigger.

@export var movement: GridMovementComponent


func _ready() -> void:
	movement.place(Grid.world_to_cell(position))
