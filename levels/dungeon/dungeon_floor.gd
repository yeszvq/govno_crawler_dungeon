class_name DungeonFloor
extends Level
## Этаж подземелья: карта генерируется из seed и глубины.


func _make_layout() -> String:
	return DungeonGenerator.generate(level_seed, depth)
