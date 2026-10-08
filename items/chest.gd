class_name Chest
extends Node2D
## Сундук. Создаётся хостом через спаунер уровня, не мешает ходить.
## Открывает первый, кто нажал «взаимодействие»: случайный предмет из loot
## уходит ему. Флаг opened синхронизируется, и у всех сундук открывается.

@export var sprite: Sprite2D
@export var interactable: Interactable
@export var closed_texture: Texture2D
@export var opened_texture: Texture2D
@export var loot: Array[ItemDefinition] = []

var opened := false:
	set(value):
		opened = value
		_show_state()


## Вызывается спаунером до добавления в дерево. data: cell.
func setup(data: Dictionary) -> void:
	position = Grid.cell_to_world(data.cell)


func _ready() -> void:
	interactable.interacted.connect(_on_interacted)
	_show_state()


func _on_interacted(by: Actor) -> void:
	var hero := by as Hero
	var item: ItemDefinition = loot.pick_random()
	hero.inventory.add(item)
	Events.item_picked_up.emit(hero, item)
	opened = true


func _show_state() -> void:
	if not is_node_ready():
		return
	sprite.texture = opened_texture if opened else closed_texture
	interactable.enabled = not opened
	if opened:
		Events.burst_requested.emit(global_position, Color(1.0, 0.8, 0.3))
