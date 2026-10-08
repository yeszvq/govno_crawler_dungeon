class_name Intent
extends RefCounted
## Намерение: что игрок или ИИ хочет сделать прямо сейчас.
## Клавиши и мозги ИИ превращаются в Intent, а что с ним делать,
## решает текущее состояние стейт-машины. Так ввод не знает про состояния,
## а состояния не знают, откуда пришла команда.

const MOVE := &"move" ## Идти в direction (пока не придёт STOP).
const STOP := &"stop" ## Отпустили все направления.
const ATTACK := &"attack" ## Ударить в сторону direction (куда целится мышь).
const INTERACT := &"interact" ## Поговорить / поднять / поднять упавшего союзника.
const DASH := &"dash" ## Рывок вперёд.

var kind: StringName
## Единичный вектор направления (или ноль).
var direction: Vector2


func _init(p_kind: StringName, p_direction := Vector2.ZERO) -> void:
	kind = p_kind
	direction = p_direction
