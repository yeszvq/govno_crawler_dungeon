class_name PhysicsLayers
extends RefCounted
## Слои столкновений (битовые маски). Названия заданы в project.godot.

## Стены, деревья, статуи, NPC.
const WORLD := 1
## Тела героев и врагов. По этому же слою удар ищет, в кого попал.
const ACTORS := 2
