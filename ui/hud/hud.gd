extends Control
## HUD: карточки героев и часы.

@export var heroes: Array[Hero] = []
@export var party_box: Container
@export var clock_label: Label


func _ready() -> void:
	for hero in heroes:
		var card := HeroCard.new()
		party_box.add_child(card)
		card.hero = hero
	Events.game_minute_passed.connect(_on_game_minute_passed)


@warning_ignore("integer_division")
func _on_game_minute_passed(total: int) -> void:
	clock_label.text = "День %d, %02d:%02d" % [
		total / GameClock.MINUTES_PER_DAY + 1, GameClock.hour, total % 60]
