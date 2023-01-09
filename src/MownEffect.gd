extends Spatial

onready var particles := $Particles

func _ready():
  var rng = RandomNumberGenerator.new()
  rng.randomize()
  particles.amount = rng.randi_range(0, 3)
  particles.emitting = true
