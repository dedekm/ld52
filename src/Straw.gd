extends Spatial

var mown := false
var mown_effect : Spatial

onready var level := get_node("/root/Level")
onready var mown_effect_scene := preload("res://src/MownEffect.tscn")

func _ready():
  $StrawSprite/HitArea.add_to_group("grass")

func mow(point: Vector3):
  $StrawSprite.global_translation.y = point.y - 1.6
  if $StrawSprite.global_translation.y < -2:
    $StrawSprite.global_translation.y = -2

  $StrawSprite.play("cut")
  $BitsSprite.show()

  var rng = RandomNumberGenerator.new()
  rng.randomize()
  $BitsSprite.rotation_degrees.z = rng.randi_range(0, 3) * 90

  if !mown:
    level.add_point()
    mown = true

  if !mown_effect:
    mown_effect = mown_effect_scene.instance()
    add_child(mown_effect)
    mown_effect.global_translation = point

func _process(delta):
  if mown_effect and not mown_effect.particles.is_emitting():
    mown_effect.queue_free()
    mown_effect = null
