extends Control

func _ready():
  pass

func _on_AnimationPlayer_animation_finished(anim_name: String):
  match anim_name:
    "fade_out":
      owner.fade_out_finished()
    "fade_in":
      owner.fade_in_finished()
