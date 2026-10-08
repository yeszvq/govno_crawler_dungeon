class_name ActorEffects
extends Node
## Оживляет картинку персонажа. Только визуал, работает на всех машинах:
## реагирует на синхронизируемые сигналы (здоровье, шаги, состояние, инвентарь),
## поэтому у клиентов всё выглядит так же, как у хоста.
##
## Каждый эффект трогает своё свойство спрайта, чтобы они не мешали друг другу:
## вспышка — self_modulate, выпад — position, походка — offset, дыхание — scale.
## Цвет по состоянию (modulate) остаётся за ActorVisual.

const FLASH_COLOR := Color(1.0, 0.35, 0.35)
const HEAL_COLOR := Color(0.45, 1.0, 0.45)
const LOOT_COLOR := Color(1.0, 0.85, 0.35)
const LUNGE_DISTANCE := 9.0
const BOB_HEIGHT := 2.5
const BOB_TIME := 0.14
## Цвет цифр урона по фракции.
const DAMAGE_COLORS: Dictionary[StringName, Color] = {
	&"heroes": Color(1.0, 0.35, 0.3),
	&"monsters": Color(1.0, 0.92, 0.5),
}

@export var actor: Actor
@export var sprite: Sprite2D
## Есть только у героев: трясём камеру, если ранили своего.
@export var camera: Camera2D
## Есть только у героев: «+Хлеб» при подборе.
@export var inventory: InventoryComponent

var _last_health := 0
var _last_item_count := 0
var _walk: Tween
## Состояние → эффект при входе в него.
var _state_effects: Dictionary[StringName, Callable] = {}


func _ready() -> void:
	_state_effects = {
		&"Attack": _lunge,
		&"Dash": _lunge,
		&"Downed": _burst.bind(Color(0.7, 0.05, 0.05)),
		&"Death": _burst.bind(Color(0.55, 0.05, 0.05)),
	}
	# Подключаемся после Actor._ready: там разложены характеристики и
	# здоровье выставлено в максимум — это не урон и не лечение.
	_connect_signals.call_deferred()


func _connect_signals() -> void:
	_last_health = actor.health.current
	actor.health.changed.connect(_on_health_changed)
	actor.state_machine.state_changed.connect(_on_state_changed)
	if inventory:
		_last_item_count = inventory.items.size()
		inventory.changed.connect(_on_inventory_changed)
	_breathe()


func _on_health_changed(current: int, _maximum: int) -> void:
	var delta := current - _last_health
	_last_health = current
	if delta < 0:
		_on_damaged(-delta)
	elif delta > 0 and actor.is_visible_in_tree():
		_float("+%d" % delta, HEAL_COLOR)


func _on_damaged(amount: int) -> void:
	_float(str(amount), DAMAGE_COLORS.get(actor.faction, Color.WHITE))
	sprite.self_modulate = FLASH_COLOR
	sprite.create_tween().tween_property(sprite, ^"self_modulate", Color.WHITE, 0.25)
	if camera and camera.enabled:
		_shake()


func _on_state_changed(_previous: StringName, current: StringName) -> void:
	_set_walking(current == &"Move")
	_state_effects.get(current, _no_effect).call()


## Пока идём — персонаж покачивается на ходу.
func _set_walking(walking: bool) -> void:
	if _walk:
		_walk.kill()
	sprite.offset.y = 0.0
	if not walking:
		return
	_walk = sprite.create_tween().set_loops()
	_walk.tween_property(sprite, ^"offset:y", -BOB_HEIGHT, BOB_TIME).set_ease(Tween.EASE_OUT)
	_walk.tween_property(sprite, ^"offset:y", 0.0, BOB_TIME).set_ease(Tween.EASE_IN)


func _on_inventory_changed(items: Array[ItemDefinition]) -> void:
	var gained := items.size() > _last_item_count and actor.is_visible_in_tree()
	_last_item_count = items.size()
	if gained:
		_float("+" + items.back().display_name, LOOT_COLOR)


func _lunge() -> void:
	var tween := sprite.create_tween()
	tween.tween_property(sprite, ^"position", actor.movement.facing * LUNGE_DISTANCE, 0.07)
	tween.tween_property(sprite, ^"position", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_BACK)


func _burst(color: Color) -> void:
	Events.burst_requested.emit(actor.global_position, color)


func _shake() -> void:
	var tween := camera.create_tween()
	for i in 4:
		tween.tween_property(camera, ^"offset", Vector2(randf_range(-3, 3), randf_range(-3, 3)), 0.03)
	tween.tween_property(camera, ^"offset", Vector2.ZERO, 0.04)


## Лёгкое «дыхание», чтобы стоящие персонажи не выглядели картинками.
func _breathe() -> void:
	var tween := sprite.create_tween().set_loops()
	tween.tween_interval(randf() * 0.6)
	tween.tween_property(sprite, ^"scale", Vector2(1.0, 1.035), 0.9).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, ^"scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE)


func _float(text: String, color: Color) -> void:
	Events.floating_text_requested.emit(text, actor.global_position, color)


func _no_effect() -> void:
	pass
