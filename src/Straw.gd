extends Spatial

onready var level := get_node("/root/Level")

func _ready():
  $HitArea.add_to_group("grass")

func mow(point: Vector3):
  translation.y = point.y - 2.2
  if translation.y < -2:
    translation.y = -2

  $AnimatedSprite3D.play("cut")
