extends StaticBody2D

func _ready():
	$light.flip_h = randi()%2
	$dark.flip_h = $light.flip_h
