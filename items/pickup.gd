class_name Pickup
extends Node2D
## Предмет на полу. Не мешает ходить; поднимает тот, кто первым
## нажал «взаимодействие» рядом, и предмет уходит ему.

@export var sprite: Sprite2D
@export var interactable: Interactable

var item: ItemDefinition


## Вызывается спаунером до добавления в дерево.
## data: item, cell, и необязательно position (точное место, где выпал).
func setup(data: Dictionary) -> void:
	item = load(data.item)
	position = data.get("position", Grid.cell_to_world(data.cell))


func _ready() -> void:
	sprite.texture = item.icon
	interactable.prompt = "Поднять: %s" % item.display_name
	interactable.interacted.connect(_on_interacted)
	# Предмет «подпрыгивает», когда выпадает.
	sprite.position.y = -10.0
	create_tween().tween_property(sprite, ^"position:y", 0.0, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _on_interacted(by: Actor) -> void:
	var hero := by as Hero
	hero.inventory.add(item)
	Events.item_picked_up.emit(hero, item)
	interactable.enabled = false
	queue_free()
