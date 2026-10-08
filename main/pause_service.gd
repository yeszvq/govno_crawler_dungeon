class_name PauseService
extends Node
## Пауза для всей сессии. Решает хост:
##  * кто-то нажал P — пауза включается/выключается для всех;
##  * все игроки одновременно в меню (инвентарь, карта, диалог) — тоже пауза.
## Решение рассылается всем, и каждая машина эмитит Events.pause_changed.

const SERVER_ID := 1

## peer_id → открыто ли у него меню. Ведёт хост.
var _menu_open: Dictionary[int, bool] = {}
var _manual := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Events.menu_toggled.connect(_on_menu_toggled)
	Events.pause_toggle_requested.connect(_on_pause_toggle_requested)
	Events.peer_left.connect(_on_peer_left)
	Events.session_ended.connect(_on_session_ended)


func _on_menu_toggled(is_open: bool) -> void:
	_report_menu.rpc_id(SERVER_ID, is_open)


func _on_pause_toggle_requested() -> void:
	_request_toggle.rpc_id(SERVER_ID)


func _on_peer_left(peer_id: int) -> void:
	_menu_open.erase(peer_id)
	_refresh()


func _on_session_ended() -> void:
	_menu_open.clear()
	_manual = false
	_apply(false)


@rpc("any_peer", "call_local", "reliable")
func _report_menu(is_open: bool) -> void:
	_menu_open[multiplayer.get_remote_sender_id()] = is_open
	_refresh()


@rpc("any_peer", "call_local", "reliable")
func _request_toggle() -> void:
	_manual = not _manual
	_refresh()


func _refresh() -> void:
	if not multiplayer.is_server():
		return
	var players := multiplayer.get_peers().size() + 1
	var everyone_in_menu := _menu_open.values().count(true) == players
	_apply.rpc(_manual or everyone_in_menu)


@rpc("authority", "call_local", "reliable")
func _apply(paused: bool) -> void:
	if get_tree().paused == paused:
		return
	get_tree().paused = paused
	Events.pause_changed.emit(paused)
