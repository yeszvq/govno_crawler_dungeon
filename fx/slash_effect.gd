class_name SlashEffect
extends Node2D
## Дуга взмаха оружием: быстро «прочерчивается» и тает.

const RADIUS := 20.0
const ARC := deg_to_rad(130.0)
const WIDTH := 4.0
const TIME := 0.22

var aim := Vector2.RIGHT
var color := Color.WHITE
## 0..1 — насколько дуга прочерчена.
var progress := 0.0:
	set(value):
		progress = value
		queue_redraw()


func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, ^"progress", 1.0, TIME * 0.6).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, ^"modulate:a", 0.0, TIME).set_delay(TIME * 0.4)
	tween.tween_callback(queue_free)


func _draw() -> void:
	var start := aim.angle() - ARC / 2.0
	draw_arc(Vector2.ZERO, RADIUS, start, start + ARC * progress, 12, color, WIDTH, true)
	draw_arc(Vector2.ZERO, RADIUS - 4.0, start, start + ARC * progress, 12, Color(color, color.a * 0.5), WIDTH * 0.7, true)
	draw_arc(Vector2.ZERO, RADIUS - 8.0, start, start + ARC * progress, 12, Color(color, color.a * 0.2), WIDTH * 0.5, true)
