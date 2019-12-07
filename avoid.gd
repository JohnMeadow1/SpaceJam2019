tool
extends Node2D

export var distance := 100.0 setget set_marker

func _ready():
	pass

func set_marker (value):
	distance = value
	update()
	
func _draw():
	if Engine.editor_hint:
		draw_circle(Vector2.ZERO, distance, Color(1,0,0,0.3) )
