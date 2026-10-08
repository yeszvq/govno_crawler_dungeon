class_name EffectsLayer
extends Node2D
## Слой мировых эффектов в Main. Ничего не знает о том, кто просит эффект:
## слушает события Events (текст, частицы, взмахи, попадания) и рисует.

const FLOAT_HEIGHT := 22.0
const FLOAT_TIME := 0.8
const BURST_PARTICLES := 18
const HIT_COLOR := Color(1.0, 0.95, 0.6)
const MISS_COLOR := Color(0.7, 0.82, 1.0)
const FONT_SIZE := 14


func _ready() -> void:
	Events.floating_text_requested.connect(_on_floating_text_requested)
	Events.burst_requested.connect(_on_burst_requested)
	Events.swing_shown.connect(_on_swing_shown)
	Events.impact_shown.connect(_on_impact_shown)


func _on_swing_shown(world_position: Vector2, aim: Vector2, color: Color) -> void:
	var slash := SlashEffect.new()
	slash.position = world_position
	slash.aim = aim
	slash.color = color
	add_child(slash)


## Попал — яркие искры, промахнулся — серое «промах» и пыль.
func _on_impact_shown(world_position: Vector2, is_hit: bool) -> void:
	if is_hit:
		_spawn_burst(world_position, HIT_COLOR, 16, 120.0, 0.3)
		_spawn_ring(world_position, HIT_COLOR)
	else:
		_on_floating_text_requested("ПРОМАХ", world_position + Vector2(0, -6), MISS_COLOR)
		_spawn_burst(world_position + Vector2(0, 8), MISS_COLOR, 8, 35.0, 0.35)


func _on_floating_text_requested(text: String, world_position: Vector2, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(100, 18)
	label.pivot_offset = label.size / 2.0
	label.position = world_position + Vector2(-50, -32)
	label.z_index = 10
	label.add_theme_font_size_override(&"font_size", FONT_SIZE)
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_constant_override(&"outline_size", 4)
	label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.9))
	label.scale = Vector2.ONE * 1.6
	add_child(label)
	var tween := label.create_tween().set_parallel()
	tween.tween_property(label, ^"scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, ^"position:y", label.position.y - FLOAT_HEIGHT, FLOAT_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(label, ^"modulate:a", 0.0, FLOAT_TIME).set_delay(FLOAT_TIME * 0.4)
	tween.chain().tween_callback(label.queue_free)


func _on_burst_requested(world_position: Vector2, color: Color) -> void:
	_spawn_burst(world_position, color, BURST_PARTICLES, 70.0, 0.6)


## Расходящееся кольцо удара.
func _spawn_ring(world_position: Vector2, color: Color) -> void:
	var ring := ImpactRing.new()
	ring.position = world_position
	ring.color = color
	add_child(ring)


func _spawn_burst(world_position: Vector2, color: Color, amount: int, speed: float, lifetime: float) -> void:
	var burst := CPUParticles2D.new()
	burst.position = world_position
	burst.one_shot = true
	burst.explosiveness = 0.9
	burst.amount = amount
	burst.lifetime = lifetime
	burst.direction = Vector2.UP
	burst.spread = 180.0
	burst.initial_velocity_min = speed * 0.4
	burst.initial_velocity_max = speed
	burst.gravity = Vector2(0, 120)
	burst.scale_amount_min = 1.5
	burst.scale_amount_max = 3.0
	burst.color = color
	burst.finished.connect(burst.queue_free)
	add_child(burst)
	burst.emitting = true
