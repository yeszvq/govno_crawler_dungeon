class_name ActorVisual
extends Node
## Картинка персонажа реагирует на смену состояния: цвет из таблицы tints.
## Работает на всех машинах, потому что state_changed есть и у клиентов.

@export var sprite: CanvasItem
@export var state_machine: StateMachine
## Состояние → оттенок. Чего нет в таблице, рисуется без оттенка.
@export var tints: Dictionary[StringName, Color] = {}


func _ready() -> void:
	state_machine.state_changed.connect(_on_state_changed)


func _on_state_changed(_previous: StringName, current: StringName) -> void:
	sprite.modulate = tints.get(current, Color.WHITE)
