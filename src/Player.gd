extends KinematicBody

const GRAVITY := 0
const MAX_SPEED := 17
const ACCEL := 4.5

var vel := Vector3()
var dir := Vector3()
var cutting := false
var cutting_enabled := true

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40
const MOUSE_SENSITIVITY = 0.09

onready var camera := $RotationHelper/Camera
onready var rotation_helper := $RotationHelper
onready var hands := $RotationHelper/Hands
onready var scythe := $RotationHelper/Hands/Scythe
onready var scythe_ray := $RotationHelper/Hands/Scythe/RayCast

func _ready():
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
  _process_input(delta)
  if cutting && cutting_enabled:
    _process_cutting()
  else:
    _process_movement(delta)

func _process_cutting():
  var collisions = []
  var play_mown_sound := false
  while scythe_ray.is_colliding():
    var obj : Object = scythe_ray.get_collider()

    if obj.is_in_group("grass"):
      obj.owner.mow(scythe_ray.get_collision_point())
      play_mown_sound = true

    collisions.append(obj)
    scythe_ray.add_exception(obj)
    scythe_ray.force_raycast_update()

  scythe_ray.clear_exceptions()

  if play_mown_sound and not $MownStreamPlayer.playing:
    $MownStreamPlayer.play()

func _process_input(_delta):
  dir = Vector3()
  var cam_xform = camera.get_global_transform()

  var input_movement_vector = Vector2()

  if Input.is_action_pressed("ui_up"):
      input_movement_vector.y += 1
  if Input.is_action_pressed("ui_down"):
      input_movement_vector.y -= 1
  if Input.is_action_pressed("ui_left"):
      input_movement_vector.x -= 1
  if Input.is_action_pressed("ui_right"):
      input_movement_vector.x = 1

  input_movement_vector = input_movement_vector.normalized()

  dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
  dir += cam_xform.basis.x.normalized() * input_movement_vector.x

  if Input.is_action_just_pressed("ui_cancel"):
    if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
      Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
      Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

  if Input.is_mouse_button_pressed(BUTTON_LEFT):
    if !cutting:
      scythe.rotation_degrees.x = -90
      scythe.rotation_degrees.y = -30
      scythe.translation.x = 0
      cutting = true
  else:
    if cutting:
      scythe.rotation_degrees.x = -20
      scythe.rotation_degrees.y = 0
      scythe.translation.x = 0.5
      hands.rotation_degrees = Vector3()
      cutting = false

func _process_movement(delta):
  dir.y = 0
  dir = dir.normalized()

  vel.y += delta * GRAVITY

  var hvel = vel
  hvel.y = 0

  var target = dir
  if cutting_enabled:
    target *= MAX_SPEED
  else:
    target *= MAX_SPEED / 2

  var accel
  if dir.dot(hvel) > 0:
    accel = ACCEL

    if not $StepsStreamPlayer.playing:
      $StepsStreamPlayer.play()
  else:
    accel = DEACCEL

    if $StepsStreamPlayer.playing:
      $StepsStreamPlayer.stop()

  hvel = hvel.linear_interpolate(target, accel*delta)
  vel.x = hvel.x
  vel.z = hvel.z
  vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
  if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
    if cutting:
      rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * 0.5 * -1))
      hands.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * 0.3 * -1))
      self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * 0.1 * -1))
    else:
      rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
      self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

      var camera_rot = rotation_helper.rotation_degrees
      camera_rot.x = clamp(camera_rot.x, -70, 70)
      rotation_helper.rotation_degrees = camera_rot
