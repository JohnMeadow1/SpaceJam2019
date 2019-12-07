extends Node2D

var darkside_count: int setget set_count
onready var full_counter: int = $YSort/Jakes.get_child_count()

func _ready() -> void:
	set_count(0)

func set_count(c: int):
	darkside_count = c
	$UI/Score/Count.text = str(c, "/", full_counter)
	
	if c == full_counter:
		get_tree().create_timer(12).connect("timeout", get_tree(), "change_scene", ["res://OverGame.tscn"])
