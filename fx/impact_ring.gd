class_name ImpactRing
extends Node2D
## Кольцо, которое быстро расширяется и гаснет в точке попадания.

const START_RADIUS := 3.0
const END_RADIUS := 16.0
const TIME := 0.2

var color := Color.WHITE
var radius := START_RADIUS:
	set(value):
		radius = value
		queue_redraw()


func _ready() -> void:
	z_index = 6
	var tween := create_tween().set_parallel()
	tween.tween_property(self, ^"radius", END_RADIUS, TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, ^"modulate:a", 0.0, TIME)
	tween.chain().tween_callback(queue_free)


func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 20, color, 2.0, true)
