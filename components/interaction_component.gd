class_name InteractionComponent
extends Node
## Взаимодействие с тем, что стоит или лежит в клетке перед персонажем.

@export var actor: Actor


func interact(cell: Vector2i) -> void:
	var target := Grid.interactable_at(cell)
	if target:
		target.interact(actor)
