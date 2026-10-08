extends Node
## Сетевая сессия: хост / подключение по IP / выход.
## Сырые сигналы MultiplayerAPI переводятся в события шины Events,
## остальная игра про ENet ничего не знает.

const DEFAULT_PORT := 24680
const MAX_CLIENTS := 3 # хост + 3 клиента = 4 героя

var is_online: bool:
	get: return multiplayer.multiplayer_peer is ENetMultiplayerPeer


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_lost)
	multiplayer.server_disconnected.connect(_on_connection_lost)


## Запустить сервер на этой машине. Возвращает код ошибки Godot (OK = 0).
func host(port: int = DEFAULT_PORT) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port, MAX_CLIENTS)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	Events.session_started.emit(true)
	Events.peer_joined.emit(multiplayer.get_unique_id())
	return OK


## Подключиться к хосту. Сессия начнётся, когда придёт connected_to_server.
func join(address: String, port: int = DEFAULT_PORT) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, port)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	return OK


func leave() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	Events.session_ended.emit()


func _on_peer_connected(peer_id: int) -> void:
	Events.peer_joined.emit(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	Events.peer_left.emit(peer_id)


func _on_connected_to_server() -> void:
	Events.session_started.emit(false)
	Events.peer_joined.emit(multiplayer.get_unique_id())


func _on_connection_lost() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	Events.session_ended.emit()
