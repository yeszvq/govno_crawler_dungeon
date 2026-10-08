class_name RestPoint
extends Interactable
## Костёр в лагере: пати спит, время проматывается, опыт переходит в уровни.

const REST_MINUTES := 8 * 60


func _init() -> void:
	prompt = "Отдохнуть"
	interacted.connect(_on_interacted)


func _on_interacted(_by: Actor) -> void:
	GameClock.advance(REST_MINUTES)
	Events.party_rested.emit()
