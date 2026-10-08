class_name AiInputComponent
extends IntentSource
## «Мозги» врага: раз в think_interval решает, что делать, и выдаёт те же
## намерения, что и клавиатура игрока. Стейт-машине без разницы, кто ей управляет.
## Думает только на хосте; у клиентов враг лишь отображается.

@export var actor: Actor
@export var movement: GridMovementComponent

var _think_timer := Timer.new()


func _ready() -> void:
	var definition := actor.stats as EnemyDefinition
	_think_timer.wait_time = definition.think_interval
	_think_timer.timeout.connect(_think)
	add_child(_think_timer)
	if multiplayer.is_server():
		_think_timer.start()


func _think() -> void:
	var target := _nearest_hero()
	if target == null:
		emit_intent(Intent.new(Intent.STOP))
		return
	var offset := target.movement.cell - movement.cell
	var direction := _direction_towards(offset)
	# Уже стоим вплотную и смотрим на цель — бьём, иначе подходим/поворачиваемся.
	var can_hit := offset.length_squared() == 1 and movement.facing == direction
	emit_intent(Intent.new(Intent.ATTACK if can_hit else Intent.MOVE, direction))


func _nearest_hero() -> Hero:
	var definition := actor.stats as EnemyDefinition
	var best: Hero = null
	var best_distance := definition.aggro_range + 1
	for hero: Hero in get_tree().get_nodes_in_group(Hero.GROUP):
		var distance := _manhattan(hero.movement.cell - movement.cell)
		if distance < best_distance and not hero.health.is_depleted:
			best = hero
			best_distance = distance
	return best


static func _manhattan(offset: Vector2i) -> int:
	return absi(offset.x) + absi(offset.y)


## Шаг по той оси, где до цели дальше.
static func _direction_towards(offset: Vector2i) -> Vector2i:
	var along_x := absi(offset.x) >= absi(offset.y)
	return Vector2i(signi(offset.x), 0) if along_x else Vector2i(0, signi(offset.y))
