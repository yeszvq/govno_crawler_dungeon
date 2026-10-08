extends Node
## Поиск игр в локальной сети.
## Хост раз в секунду рассылает UDP-broadcast «тут идёт игра»,
## меню подключения слушает порт и сообщает о находках через Events.lan_host_found.
## Сокет нельзя «подписать на сигнал», поэтому его читает таймер, и только пока
## открыт список игр.

const PORT := 24681
const MAGIC := "last-campfire/1"
const BROADCAST_ADDRESS := "255.255.255.255"

## Имя игры в списке у других игроков.
var host_name := "Костёр"

var _socket := PacketPeerUDP.new()
var _timer := Timer.new()
var _on_tick := Callable()


func _ready() -> void:
	_timer.wait_time = 1.0
	_timer.timeout.connect(func() -> void: _on_tick.call())
	add_child(_timer)
	Events.session_started.connect(_on_session_started)
	Events.session_ended.connect(stop)


## Начать слушать сеть (экран подключения открыт).
func start_browsing() -> void:
	stop()
	_socket.bind(PORT)
	_start(_poll)


func stop() -> void:
	_timer.stop()
	_socket.close()


func _on_session_started(is_host: bool) -> void:
	stop()
	if is_host:
		_socket.set_broadcast_enabled(true)
		_socket.set_dest_address(BROADCAST_ADDRESS, PORT)
		_start(_advertise)


func _start(tick: Callable) -> void:
	_on_tick = tick
	_timer.start()


func _advertise() -> void:
	var info := {
		magic = MAGIC,
		name = host_name,
		players = multiplayer.get_peers().size() + 1,
	}
	_socket.put_packet(JSON.stringify(info).to_utf8_buffer())


func _poll() -> void:
	while _socket.get_available_packet_count() > 0:
		var packet := _socket.get_packet().get_string_from_utf8()
		var info: Variant = JSON.parse_string(packet)
		if info is Dictionary and info.get("magic") == MAGIC:
			Events.lan_host_found.emit(_socket.get_packet_ip(), str(info.name), int(info.players))
