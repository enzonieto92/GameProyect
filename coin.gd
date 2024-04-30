extends Node3D

func _ready():
	var animation = get_node("AnimationPlayer")
	
	animation.play("Idle")

