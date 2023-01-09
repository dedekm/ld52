extends Spatial

const morning_sun_color := Color("fcd14d")
const noon_sun_color := Color("ffe484")
const evening_sun_color := Color("f96229")

const morning_sky_color := Color("a5d6f1")
const noon_sky_color := Color("29cce5")
const evening_sky_color := Color("001f38")

var current_points := 0
var max_points := 0
var completed := 0.0

onready var main_light := $DirectionalLight
onready var sun_helper := $SunHelper
onready var sun_material : SpatialMaterial = $SunHelper/SunSphere.get_surface_material(0)
onready var enviroment : Environment = $WorldEnvironment.environment

func _ready():
  var grass := $Grass
  var straw_scene = load("res://src/Straw.tscn")
  var width = 20
  for x in width:
    for z in width:
        var straw_instance = straw_scene.instance()
        straw_instance.set_name("Straw" + str(x) + str(z))
        straw_instance.translation.x = (x - width / 2) * 0.5
        straw_instance.translation.z = (z - width / 2) * 0.5

        var rng = RandomNumberGenerator.new()
        rng.randomize()
        straw_instance.translation.y -= rng.randi_range(0, 3) * 0.1

        grass.add_child(straw_instance)

        max_points += 1

  _update_enviroment()

  sun_material.albedo_color = morning_sun_color
  enviroment.background_color = morning_sky_color

func _update_enviroment():
  completed = current_points / float(max_points)

  # TODO: rm this
  $ScoreLabel.text = String(completed)

  var coef : float
  if completed < 0.5:
    coef = completed * 2
    sun_material.albedo_color = morning_sun_color.linear_interpolate(noon_sun_color, coef)
    enviroment.background_color = morning_sky_color.linear_interpolate(noon_sky_color, coef)
  else:
    coef = (completed - 0.5) * 2
    sun_material.albedo_color = noon_sun_color.linear_interpolate(evening_sun_color, coef)
    enviroment.background_color = noon_sky_color.linear_interpolate(evening_sky_color, coef)

  main_light.light_color = sun_material.albedo_color.linear_interpolate(Color.white, 0.1)
  main_light.rotation_degrees.x = -20 - (150 * completed)
  sun_helper.rotation_degrees.x = -10 - (160 * completed)

func add_point():
  current_points += 1
  _update_enviroment()
