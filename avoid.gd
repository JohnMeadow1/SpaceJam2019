tool
extends Node2D

export var avoid_distance := 100.0 setget set_marker

func _ready():
	pass

func set_marker (value):
	avoid_distance = value
	update()
	
func _draw():
	if Engine.editor_hint:
		draw_circle(Vector2.ZERO, avoid_distance, Color(1,0,0,0.3) )
