extends Node2D

var darkside_count: int setget set_count

func set_count(c: int):
	darkside_count = c
	$UI/Score/Count.text = str(c)
