class_name Hero
extends Actor
## Герой. Четыре героя всегда стоят в Main/Players и никогда не пересоздаются:
## меняется только уровень под ними. Герой «включается», когда PartyService
## закрепляет его слот за игроком (owner_peer_id != 0).

## Группа активных героев (по ней враги ищут цели).
const GROUP := &"heroes"

@export_range(0, 3) var slot := 0
@export var input: InputComponent
@export var camera: Camera2D
@export var inventory: InventoryComponent
@export var needs: NeedsComponent
@export var interaction: InteractionComponent

## Чей это герой. 0 — слот свободен, герой спрятан и выключен.
var owner_peer_id := 0:
	set(value):
		owner_peer_id = value
		input.owner_peer_id = value
		_set_active(value != 0)
		camera.enabled = input.is_local()
		if camera.enabled:
			camera.make_current()

## Состояние → глобальное событие при входе в него.
var _enter_events: Dictionary[StringName, Signal] = {}
## Переход «откуда>куда» → глобальное событие.
var _transition_events: Dictionary[StringName, Signal] = {}


func _ready() -> void:
	super()
	_enter_events = {
		&"Downed": Events.hero_downed,
		&"Dead": Events.hero_died,
	}
	_transition_events = {
		&"Downed>Idle": Events.hero_revived,
		&"Dead>Idle": Events.hero_respawned,
	}
	state_machine.state_changed.connect(_on_state_changed)
	_set_active(false)


func apply_stats() -> void:
	super()
	var hero_class := stats as ClassDefinition
	inventory.clear()
	for item in hero_class.starting_items:
		inventory.add(item)


## Хост ставит героя на точку появления нового уровня.
## Павшие и упавшие при этом воскресают (смерть = возвращение в лагерь).
func enter_level(cell: Vector2i) -> void:
	movement.place(Grid.cell_to_world(cell))
	if health.is_depleted:
		health.reset()
		needs.reset()
		state_machine.transition_to(&"Idle")


func _set_active(active: bool) -> void:
	visible = active
	process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	# Спрятанный герой не должен ни во что упираться.
	collision_layer = PhysicsLayers.ACTORS if active else 0
	if active:
		add_to_group(GROUP)
	else:
		remove_from_group(GROUP)


func _on_state_changed(previous: StringName, current: StringName) -> void:
	var transition := StringName("%s>%s" % [previous, current])
	if _enter_events.has(current):
		_enter_events[current].emit(self)
	if _transition_events.has(transition):
		_transition_events[transition].emit(self)
