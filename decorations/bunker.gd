extends StaticBody2D

var to_kill

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("lukes") and body.lifes == 0:
		$AnimationPlayer.play("door_open")
		body.frozen = true
		to_kill = body


func kill_him():
	to_kill.queue_free()
	to_kill = null
	get_tree().get_nodes_in_group("darkside").front().the_sith()
