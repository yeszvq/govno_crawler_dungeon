class_name LevelExit
extends Interactable
## Лестница: просит сервер сменить уровень.

var target: StringName


func _init(p_target: StringName = &"") -> void:
	target = p_target
	prompt = "Перейти"
	interacted.connect(_on_interacted)


func _on_interacted(_by: Actor) -> void:
	Events.level_change_requested.emit(target)
