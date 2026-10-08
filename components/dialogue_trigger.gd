class_name DialogueTrigger
extends Node
## Начинает диалог Dialogue Manager, когда с владельцем взаимодействуют.
## Взаимодействие обрабатывает хост, а диалог показываем только тому игроку,
## который подошёл: RPC на его машину → Events.dialogue_requested → UI.

@export var interactable: Interactable
@export var dialogue: DialogueResource
@export var cue := "start"


func _ready() -> void:
	interactable.interacted.connect(_on_interacted)


func _on_interacted(by: Actor) -> void:
	_show.rpc_id((by as Hero).owner_peer_id)


@rpc("authority", "call_local", "reliable")
func _show() -> void:
	Events.dialogue_requested.emit(dialogue, cue)
