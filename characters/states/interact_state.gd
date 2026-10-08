class_name InteractState
extends State
## Мгновенное действие с клеткой перед собой и сразу обратно.

@export var movement: GridMovementComponent
@export var interaction: InteractionComponent


func enter(_data: Dictionary = {}) -> void:
	interaction.interact(movement.facing_cell)
	machine.resume.call_deferred()
