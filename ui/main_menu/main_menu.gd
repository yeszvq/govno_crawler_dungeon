extends Control
## Стартовое меню: создать игру, подключиться по IP или выбрать игру из списка LAN.

@export var host_button: Button
@export var address_edit: LineEdit
@export var join_button: Button
@export var lan_list: ItemList
@export var status_label: Label

## Адрес найденной игры → её строка в списке.
var _found: Dictionary[String, int] = {}


func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	lan_list.item_activated.connect(_on_lan_item_activated)
	visibility_changed.connect(_on_visibility_changed)
	Events.lan_host_found.connect(_on_lan_host_found)
	Events.session_ended.connect(_on_session_ended)
	_on_visibility_changed()


func _on_host_pressed() -> void:
	_report(Net.host(), "Не удалось создать игру")


func _on_join_pressed() -> void:
	_join(address_edit.text.strip_edges())


func _on_lan_item_activated(index: int) -> void:
	_join(lan_list.get_item_metadata(index))


func _join(address: String) -> void:
	status_label.text = "Подключаюсь к %s..." % address
	_report(Net.join(address), "Не удалось подключиться")


func _report(error: Error, message: String) -> void:
	if error != OK:
		status_label.text = "%s: %s" % [message, error_string(error)]


func _on_visibility_changed() -> void:
	_found.clear()
	lan_list.clear()
	if visible:
		LanDiscovery.start_browsing()


func _on_lan_host_found(address: String, host_name: String, players: int) -> void:
	var text := "%s — %s (%d/4)" % [host_name, address, players]
	if not _found.has(address):
		_found[address] = lan_list.add_item(text)
		lan_list.set_item_metadata(_found[address], address)
	lan_list.set_item_text(_found[address], text)


func _on_session_ended() -> void:
	status_label.text = "Соединение закрыто"
