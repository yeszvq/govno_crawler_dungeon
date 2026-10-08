extends Node
## Игровое время. 1 реальная секунда = 1 игровая минута, сутки = 24 минуты.
## Тикает только у хоста и рассылает минуту всем, поэтому время у всех одинаковое.
## На паузе (get_tree().paused) таймер стоит сам.

const MINUTES_PER_DAY := 24 * 60

var total_minutes: int = 8 * 60 # игра начинается в 8:00

@warning_ignore("integer_division")
var hour: int:
	get: return (total_minutes % MINUTES_PER_DAY) / 60

var _timer := Timer.new()


func _ready() -> void:
	_timer.wait_time = 1.0
	_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	_timer.timeout.connect(_on_tick)
	add_child(_timer)
	Events.session_started.connect(_on_session_started)
	Events.session_ended.connect(_timer.stop)
	Events.peer_joined.connect(_on_peer_joined)


## Промотать время (например, сон). Вызывается только на хосте.
func advance(minutes: int) -> void:
	_set_minutes.rpc(total_minutes + minutes)


func _on_session_started(is_host: bool) -> void:
	_timer.stop()
	if is_host:
		_timer.start()


func _on_peer_joined(peer_id: int) -> void:
	# Новенькому сразу отдаём текущее время.
	if multiplayer.is_server() and peer_id != multiplayer.get_unique_id():
		_set_minutes.rpc_id(peer_id, total_minutes)


func _on_tick() -> void:
	_set_minutes.rpc(total_minutes + 1)


@rpc("authority", "call_local", "unreliable_ordered")
func _set_minutes(value: int) -> void:
	total_minutes = value
	Events.game_minute_passed.emit(total_minutes)
