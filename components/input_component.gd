class_name InputComponent
extends IntentSource
## Клавиатура и мышь игрока → намерения.
##
## Читает ввод только на машине владельца героя и отправляет намерение хосту
## по RPC. Хост проверяет, что прислал именно владелец, и отдаёт намерение
## стейт-машине. У хоста RPC вызывается локально (call_local), так что путь
## одинаковый для всех игроков.

## Клавиша направления → куда идти. Зажатые складываются (диагонали).
const DIRECTIONS: Dictionary[StringName, Vector2] = {
	&"move_up": Vector2.UP,
	&"move_down": Vector2.DOWN,
	&"move_left": Vector2.LEFT,
	&"move_right": Vector2.RIGHT,
}
## Клавиша действия → намерение.
const ACTIONS: Dictionary[StringName, StringName] = {
	&"attack": Intent.ATTACK,
	&"interact": Intent.INTERACT,
	&"dash": Intent.DASH,
}
const SERVER_ID := 1

## Тело героя: от него считается прицел мыши.
@export var body: Node2D

## Чей это герой. 0 — никто не управляет.
var owner_peer_id := 0:
	set(value):
		owner_peer_id = value
		_update_listening()

var _pressed: Dictionary[StringName, bool] = {}
var _menu_open := false
## Действие с клавиатуры → куда направить (рывок — куда идём, остальное — куда смотрим).
## Действие с мыши всегда направлено в курсор.
var _aims: Dictionary[StringName, Callable] = {}


func _ready() -> void:
	_aims = {
		&"attack": _no_aim,
		&"dash": _held,
		&"interact": _no_aim,
	}
	set_process_unhandled_input(false)
	Events.menu_toggled.connect(_on_menu_toggled)
	Events.session_started.connect(_on_session_started)


func is_local() -> bool:
	return owner_peer_id != 0 and owner_peer_id == multiplayer.get_unique_id()


func _unhandled_input(event: InputEvent) -> void:
	for action: StringName in DIRECTIONS:
		_read_direction(event, action)
	for action: StringName in ACTIONS:
		_read_action(event, action)


func _read_direction(event: InputEvent, action: StringName) -> void:
	if event.is_action_pressed(action):
		_pressed[action] = true
		_send_held()
	elif event.is_action_released(action):
		_pressed.erase(action)
		_send_held()


func _read_action(event: InputEvent, action: StringName) -> void:
	if event.is_action_pressed(action):
		var aim: Vector2 = _mouse_aim() if event is InputEventMouseButton else _aims[action].call()
		_receive.rpc_id(SERVER_ID, ACTIONS[action], aim)


func _held() -> Vector2:
	var sum := Vector2.ZERO
	for action: StringName in _pressed:
		sum += DIRECTIONS[action]
	return sum.normalized()


## Без направления: состояние возьмёт текущий взгляд.
func _no_aim() -> Vector2:
	return Vector2.ZERO


func _mouse_aim() -> Vector2:
	return body.global_position.direction_to(body.get_global_mouse_position())


func _send_held() -> void:
	var direction := _held()
	var kind := Intent.STOP if direction == Vector2.ZERO else Intent.MOVE
	_receive.rpc_id(SERVER_ID, kind, direction)


@rpc("any_peer", "call_local", "reliable")
func _receive(kind: StringName, direction: Vector2) -> void:
	# Хост слушает только хозяина героя: чужой клиент не может им управлять.
	if multiplayer.get_remote_sender_id() != owner_peer_id:
		return
	emit_intent(Intent.new(kind, direction))


func _update_listening() -> void:
	set_process_unhandled_input(is_local() and not _menu_open)


func _on_menu_toggled(is_open: bool) -> void:
	_menu_open = is_open
	_update_listening()
	# Открыли меню на ходу — останавливаемся, а не идём в стену до закрытия.
	if is_open and is_local() and not _pressed.is_empty():
		_pressed.clear()
		_send_held()


func _on_session_started(_is_host: bool) -> void:
	# После подключения у машины новый id: пересчитываем, наш ли это герой.
	_update_listening()
