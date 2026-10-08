class_name AiInputComponent
extends IntentSource
## «Мозги» врага: раз в think_interval решает, что делать, и выдаёт те же
## намерения, что и клавиатура игрока. Стейт-машине без разницы, кто ей управляет.
## Думает только на хосте; у клиентов враг лишь отображается.

@export var actor: Actor
@export var attack: AttackComponent

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
	var to_target := target.global_position - actor.global_position
	var in_reach := to_target.length() <= attack.reach + attack.radius
	var intent := Intent.new(Intent.ATTACK, to_target.normalized()) if in_reach else Intent.new(Intent.MOVE, _steer(target))
	emit_intent(intent)


## Направление к следующей точке пути (в обход стен).
func _steer(target: Hero) -> Vector2:
	var path := Grid.find_path(actor.global_position, target.global_position)
	var waypoint := path[1] if path.size() > 2 else target.global_position
	return (waypoint - actor.global_position).normalized()


func _nearest_hero() -> Hero:
	var definition := actor.stats as EnemyDefinition
	var best: Hero = null
	var best_distance := definition.aggro_range * Grid.CELL_SIZE
	for hero: Hero in get_tree().get_nodes_in_group(Hero.GROUP):
		var distance := actor.global_position.distance_to(hero.global_position)
		if distance < best_distance and not hero.health.is_depleted:
			best = hero
			best_distance = distance
	return best
