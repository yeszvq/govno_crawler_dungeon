class_name LevelExit
extends Interactable
## Лестница: просит сервер сменить уровень.

const PROMPTS: Dictionary[StringName, String] = {
	&"camp": "Подняться в лагерь",
	&"dungeon": "Спуститься глубже",
}

var target: StringName


func _init(p_target: StringName = &"") -> void:
	target = p_target
	prompt = PROMPTS.get(target, "Перейти")
	interacted.connect(_on_interacted)


func _on_interacted(_by: Actor) -> void:
	Events.level_change_requested.emit(target)
