extends Spatial

func _ready():
  pass

func cut(point: Vector3):
  translation.y = point.y - 2.2
  if translation.y < -2:
    translation.y = -2

  $AnimatedSprite3D.play("cut")
