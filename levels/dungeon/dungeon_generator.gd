class_name DungeonGenerator
extends RefCounted
## Простой генератор «комнаты + коридоры». Возвращает текст в формате Level.layout.
## Один и тот же seed даёт одну и ту же карту, поэтому по сети шлём только seed.

const WIDTH := 48
const HEIGHT := 32
const ROOM_ATTEMPTS := 40
const MIN_ROOM := 4
const MAX_ROOM := 9
## Шанс сундука в комнате (кроме стартовой и последней).
const CHEST_CHANCE := 0.4
## С какого размера в комнате ставим колонны по углам (символ «o»).
const PILLAR_ROOM := 6


static func generate(level_seed: int, depth: int) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = level_seed
	var map: Array[Array] = []
	for y in HEIGHT:
		var row := []
		row.resize(WIDTH)
		row.fill("#")
		map.append(row)

	var rooms: Array[Rect2i] = []
	for attempt in ROOM_ATTEMPTS:
		var size := Vector2i(rng.randi_range(MIN_ROOM, MAX_ROOM), rng.randi_range(MIN_ROOM, MAX_ROOM))
		var room := Rect2i(Vector2i(rng.randi_range(1, WIDTH - size.x - 1), rng.randi_range(1, HEIGHT - size.y - 1)), size)
		if rooms.any(func(other: Rect2i) -> bool: return other.grow(1).intersects(room)):
			continue
		_carve(map, room)
		if not rooms.is_empty():
			_carve_corridor(map, rooms.back().get_center(), room.get_center(), rng)
		rooms.append(room)

	_place_start(map, rooms.front())
	_mark(map, rooms.back().get_center(), ">")
	for room: Rect2i in rooms.slice(1, rooms.size() - 1):
		_place_pillars(map, room)
		_place_enemies(map, room, rng, depth)
		_place_chest(map, room, rng)
	return "\n".join(PackedStringArray(map.map(func(row: Array) -> String: return "".join(PackedStringArray(row)))))


static func _carve(map: Array[Array], room: Rect2i) -> void:
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			map[y][x] = "."


static func _carve_corridor(map: Array[Array], from: Vector2i, to: Vector2i, rng: RandomNumberGenerator) -> void:
	# Г-образный коридор: сначала по одной оси, потом по другой.
	var corner := Vector2i(to.x, from.y) if rng.randi() % 2 == 0 else Vector2i(from.x, to.y)
	_carve(map, Rect2i(from.min(corner), (from - corner).abs() + Vector2i.ONE))
	_carve(map, Rect2i(corner.min(to), (corner - to).abs() + Vector2i.ONE))


static func _place_start(map: Array[Array], room: Rect2i) -> void:
	var center := room.get_center()
	_mark(map, center + Vector2i.LEFT, "<")
	for offset: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
		_mark(map, center + offset, "P")


## Колонны на шаг от углов: вокруг каждой остаётся пол, так что проходы не перекрываются.
static func _place_pillars(map: Array[Array], room: Rect2i) -> void:
	if room.size.x < PILLAR_ROOM or room.size.y < PILLAR_ROOM:
		return
	var inner := room.grow(-1)
	for cell: Vector2i in [inner.position, Vector2i(inner.end.x - 1, inner.position.y), Vector2i(inner.position.x, inner.end.y - 1), inner.end - Vector2i.ONE]:
		if map[cell.y][cell.x] == ".":
			_mark(map, cell, "o")


static func _place_enemies(map: Array[Array], room: Rect2i, rng: RandomNumberGenerator, depth: int) -> void:
	for i in rng.randi_range(0, 1 + depth):
		var cell := Vector2i(rng.randi_range(room.position.x, room.end.x - 1), rng.randi_range(room.position.y, room.end.y - 1))
		if map[cell.y][cell.x] == ".":
			_mark(map, cell, "r")


static func _place_chest(map: Array[Array], room: Rect2i, rng: RandomNumberGenerator) -> void:
	var cell := Vector2i(rng.randi_range(room.position.x, room.end.x - 1), rng.randi_range(room.position.y, room.end.y - 1))
	if rng.randf() < CHEST_CHANCE and map[cell.y][cell.x] == ".":
		_mark(map, cell, "c")


static func _mark(map: Array[Array], cell: Vector2i, symbol: String) -> void:
	map[cell.y][cell.x] = symbol
