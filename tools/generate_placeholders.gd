extends SceneTree
## Рисует временную графику (цветные квадратики) и TileSet к ней.
## Когда положите 32rogues в assets/32rogues/, замените текстуры в data/*.tres
## и атлас в assets/placeholder/tileset.tres.
##
## Запуск (дважды: первый раз рисует png, после импорта собирает TileSet):
##     godot --headless --script res://tools/generate_placeholders.gd
##     godot --headless --import
##     godot --headless --script res://tools/generate_placeholders.gd

const DIR := "res://assets/placeholder/"
const CELL := 32

## Тайлы атласа по порядку: пол, стена, спуск, подъём, костёр.
const TILE_COLORS: Array[Color] = [
	Color("2b2b33"), Color("6b5a4a"), Color("1a1a1a"), Color("c9b48a"), Color("e0662b"),
]

const SPRITES: Dictionary[String, Color] = {
	"warrior": Color("c0392b"),
	"rogue": Color("27ae60"),
	"cleric": Color("f1c40f"),
	"mage": Color("2980b9"),
	"rat": Color("8e6e53"),
	"npc": Color("9b59b6"),
	"item": Color("f39c12"),
}


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
	_save_tiles()
	for sprite_name: String in SPRITES:
		_save_sprite(sprite_name, SPRITES[sprite_name])
	quit()


func _save_tiles() -> void:
	var image := Image.create_empty(CELL * TILE_COLORS.size(), CELL, false, Image.FORMAT_RGBA8)
	for i in TILE_COLORS.size():
		image.fill_rect(Rect2i(i * CELL, 0, CELL, CELL), TILE_COLORS[i])
		image.fill_rect(Rect2i(i * CELL + 1, 1, CELL - 2, CELL - 2), TILE_COLORS[i].lightened(0.08))
	image.save_png(DIR + "tiles.png")
	if not ResourceLoader.exists(DIR + "tiles.png"):
		print("tiles.png ещё не импортирован: запустите godot --headless --import и этот скрипт ещё раз")
		return

	var source := TileSetAtlasSource.new()
	source.texture = load(DIR + "tiles.png")
	source.texture_region_size = Vector2i(CELL, CELL)
	for i in TILE_COLORS.size():
		source.create_tile(Vector2i(i, 0))
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(CELL, CELL)
	tile_set.add_source(source, 0)
	ResourceSaver.save(tile_set, DIR + "tileset.tres")


func _save_sprite(sprite_name: String, color: Color) -> void:
	var image := Image.create_empty(CELL, CELL, false, Image.FORMAT_RGBA8)
	image.fill_rect(Rect2i(9, 4, 14, 10), color.lightened(0.3)) # голова
	image.fill_rect(Rect2i(7, 14, 18, 14), color) # тело
	image.save_png(DIR + sprite_name + ".png")
