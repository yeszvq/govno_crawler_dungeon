class_name FlickerLight
extends PointLight2D
## Живой огонь: свет слегка дрожит по яркости и размеру. Крутится бесконечным
## твином, а не в _process.

@export var energy_jitter := 0.25
@export var scale_jitter := 0.08
@export var period := 0.12


func _ready() -> void:
	var base_energy := energy
	var base_scale := texture_scale
	var tween := create_tween().set_loops()
	for i in 6:
		tween.tween_property(self, ^"energy", base_energy + randf_range(-energy_jitter, energy_jitter), period * randf_range(0.6, 1.4))
		tween.parallel().tween_property(self, ^"texture_scale", base_scale * (1.0 + randf_range(-scale_jitter, scale_jitter)), period)
