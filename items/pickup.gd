class_name Pickup
extends Node2D
## Предмет на полу. Не мешает ходить; поднимает тот, кто первым
## нажал «взаимодействие» на этой клетке, и предмет уходит ему.

@export var sprite: Sprite2D
@export var interactable: Interactable

var item: ItemDefinition
var cell := Vector2i.ZERO


## Вызывается спаунером до добавления в дерево. data: item, cell.
func setup(data: Dictionary) -> void:
	item = load(data.item)
	cell = data.cell
	position = Grid.cell_to_world(cell)


func _ready() -> void:
	sprite.texture = item.icon
	interactable.interacted.connect(_on_interacted)


func _enter_tree() -> void:
	Grid.add_floor_interactable(interactable, cell)


func _exit_tree() -> void:
	Grid.remove_floor_interactable(interactable, cell)


func _on_interacted(by: Actor) -> void:
	var hero := by as Hero
	hero.inventory.add(item)
	Events.item_picked_up.emit(hero, item)
	interactable.enabled = false
	queue_free()
