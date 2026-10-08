class_name InteractionComponent
extends Node
## Взаимодействие с ближайшим, что есть рядом (в радиусе reach).

@export var actor: Actor
@export var reach := 30.0


## Ближайший доступный Interactable рядом (не свой) или null.
func find_target() -> Interactable:
	var best: Interactable = null
	var best_distance := reach
	if not actor.is_inside_tree():
		return best
	for node in actor.get_tree().get_nodes_in_group(Interactable.GROUP):
		var target := node as Interactable
		var distance := actor.global_position.distance_to(target.global_position)
		if target.enabled and target.get_parent() != actor and distance <= best_distance:
			best = target
			best_distance = distance
	return best


func interact() -> void:
	var target := find_target()
	if target:
		target.interact(actor)
