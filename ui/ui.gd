extends CanvasLayer
## Корень интерфейса. Показывает меню или HUD по событиям сессии,
## ловит «интерфейсные» клавиши (пауза, инвентарь) и показывает диалоги.

@export var main_menu: Control
@export var hud: Control
@export var inventory_panel: Control
@export var pause_overlay: Control
## Чёрный экран для плавной смены уровня.
@export var fade: ColorRect

## Клавиша → что сделать.
var _actions: Dictionary[StringName, Callable] = {}
var _in_dialogue := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_actions = {
		&"pause": func() -> void: Events.pause_toggle_requested.emit(),
		&"inventory": _toggle_menu.bind(inventory_panel),
	}
	Events.session_started.connect(_on_session_started)
	Events.session_ended.connect(_on_session_ended)
	Events.pause_changed.connect(_on_pause_changed)
	Events.level_loaded.connect(_on_level_loaded)
	Events.dialogue_requested.connect(_on_dialogue_requested)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	_on_session_ended()


func _unhandled_input(event: InputEvent) -> void:
	for action: StringName in _actions:
		if hud.visible and event.is_action_pressed(action):
			_actions[action].call()
			get_viewport().set_input_as_handled()


func _toggle_menu(menu: Control) -> void:
	menu.visible = not menu.visible
	Events.menu_toggled.emit(menu.visible)


func _on_session_started(_is_host: bool) -> void:
	main_menu.hide()
	hud.show()


func _on_session_ended() -> void:
	main_menu.show()
	hud.hide()
	inventory_panel.hide()
	pause_overlay.hide()
	fade.color.a = 0.0


## Новый уровень проявляется из темноты.
func _on_level_loaded(_level: Level) -> void:
	fade.color.a = 1.0
	fade.create_tween().tween_property(fade, ^"color:a", 0.0, 0.6)


func _on_pause_changed(is_paused: bool) -> void:
	pause_overlay.visible = is_paused


func _on_dialogue_requested(resource: Resource, cue: String) -> void:
	_in_dialogue = true
	Events.menu_toggled.emit(true)
	DialogueManager.show_dialogue_balloon(resource, cue)


func _on_dialogue_ended(_resource: Resource) -> void:
	if not _in_dialogue:
		return
	_in_dialogue = false
	Events.menu_toggled.emit(false)
	Events.dialogue_finished.emit()
