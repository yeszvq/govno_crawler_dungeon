class_name Interactable
extends Node
## «С этим можно взаимодействовать»: NPC, предмет на полу, лестница,
## упавший союзник. Сам ничего не делает, только сообщает interacted,
## а реагируют соседние компоненты (DialogueTrigger, Pickup и т.д.).
##
## Узел должен называться Interactable: Grid ищет его у того, кто стоит в клетке.

signal interacted(by: Actor)

@export var enabled := true
## Подсказка в интерфейсе («Поговорить», «Поднять»).
@export var prompt := ""


func interact(by: Actor) -> void:
	if enabled:
		interacted.emit(by)
