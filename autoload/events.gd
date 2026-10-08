extends Node
## Глобальная шина сигналов. Подписаться и отправить можно из любого места:
##     Events.hero_died.connect(_on_hero_died)
##     Events.hero_died.emit(hero)
##
## Шина ЛОКАЛЬНАЯ: по сети она ничего не передаёт. Если событие должно
## случиться у всех игроков, его рассылает сетевой слой (Net, сервисы в main/,
## RPC в компонентах), а уже он эмитит сигнал здесь на каждой машине.
##
## Сюда попадают только события, которые нужны нескольким несвязанным системам.
## Всё, что касается одного персонажа (урон, смена состояния), живёт в сигналах
## его компонентов.
##
## Где событие эмитится (у всех или только у хоста), написано у каждого сигнала.

@warning_ignore_start("unused_signal")

# --- Сессия и игроки ---------------------------------------------------------

## Сессия началась: мы хост (is_host = true) или подключились к хосту.
signal session_started(is_host: bool)
## Сессия закончилась (вышли сами или отвалились от хоста).
signal session_ended
## Игрок подключился / отключился (на всех машинах).
signal peer_joined(peer_id: int)
signal peer_left(peer_id: int)
## Слот героя (0..3) закреплён за игроком. peer_id = 0 значит слот свободен.
signal party_slot_assigned(slot: int, peer_id: int)
## Найден хост в локальной сети.
signal lan_host_found(address: String, host_name: String, players: int)

# --- Мир и уровни -------------------------------------------------------------

## Попросить сменить уровень (лагерь, этаж подземелья). Выполняет только хост.
signal level_change_requested(level_id: StringName)
## Уровень загружен и стоит в Main на всех машинах.
signal level_loaded(level: Level)
## Прошла игровая минута (1 реальная секунда). total — минут с начала игры.
signal game_minute_passed(total: int)
## Пати поспала у костра: опыт навыков превращается в уровни. Только на хосте.
signal party_rested

# --- Герои -------------------------------------------------------------------

## Смена состояния героя. На всех машинах (из синхронизированного state_name).
signal hero_downed(hero: Hero)
signal hero_revived(hero: Hero)
signal hero_died(hero: Hero)
signal hero_respawned(hero: Hero)

# --- Предметы и бой ------------------------------------------------------------

## Только на хосте: там считается бой и подбор лута.
signal item_picked_up(hero: Hero, item: ItemDefinition)
signal damage_dealt(attacker: Node, target: Node, amount: int)

# --- Интерфейс, пауза, диалоги -------------------------------------------------

## Локальный игрок открыл или закрыл меню (инвентарь, персонаж, карта).
signal menu_toggled(is_open: bool)
## Игру поставили на паузу или сняли (на всех машинах).
signal pause_changed(is_paused: bool)
## Локальный игрок хочет поставить/снять паузу (кнопка P).
signal pause_toggle_requested
## Показать диалог локальному игроку.
signal dialogue_requested(resource: Resource, cue: String)
signal dialogue_finished
