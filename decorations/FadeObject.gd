extends StaticBody2D

var player_in: bool

func _ready():
	$light.flip_h = bool(randi()%2)
	$dark.flip_h = $light.flip_h

func _process(delta: float) -> void:
	if player_in:
		if modulate.a > 0.3:
			modulate.a -= delta
	else:
		if modulate.a < 1:
			modulate.a += delta

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("darkside"):
		player_in = true

func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("darkside"):
		player_in = false
