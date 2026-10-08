class_name Interactable
extends Node2D
## «С этим можно взаимодействовать»: NPC, предмет на полу, сундук, лестница,
## упавший союзник. Сам ничего не делает, только сообщает interacted,
## а реагируют соседние компоненты (DialogueTrigger, Pickup и т.д.).
## Стоит там же, где его владелец; ищут его по группе и расстоянию.

signal interacted(by: Actor)

const GROUP := &"interactables"

@export var enabled := true:
	set(value):
		enabled = value
		Events.interactables_changed.emit()
## Подсказка над целью: «[E] Поговорить».
@export var prompt := ""


func _enter_tree() -> void:
	add_to_group(GROUP)
	Events.interactables_changed.emit()


func _exit_tree() -> void:
	# Убираем из группы сразу, чтобы подписчики уже не нашли уходящий объект.
	remove_from_group(GROUP)
	Events.interactables_changed.emit()


func interact(by: Actor) -> void:
	if enabled:
		interacted.emit(by)
