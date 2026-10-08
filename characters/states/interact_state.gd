class_name InteractState
extends State
## Мгновенное действие с ближайшим интерактивным объектом и сразу обратно.

@export var interaction: InteractionComponent


func enter(_data: Dictionary = {}) -> void:
	interaction.interact()
	machine.resume.call_deferred()
