# Dungeon Crawl 32x32 (ProjectUtumno)

Лист `project_utumno.png` из набора Dungeon Crawl Stone Soup 32x32 (ProjectUtumno), лицензия CC0.
Листом пользуются напрямую:

* `tileset.tres` — TileSet уровней. Нужный тайл добавляется в редакторе TileSet
  или в `levels/level.gd` / `floor_tile` / `wall_tile` у сцены уровня по координатам (столбец, строка).
* `sprites/*.tres` — AtlasTexture с вырезанными персонажами и предметами для `data/*.tres`.

Координаты в клетках по 32 px: тайл в столбце 43, строке 14 — это `Vector2i(43, 14)`.
