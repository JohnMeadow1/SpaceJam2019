extends Area2D

const CHARGE_MAX := 4.0

onready var sprite: Sprite = $Sprite
onready var dark: Node2D = $LightScale

var dark_side_in: bool
var charge_timer: float

func _process(delta: float) -> void:
	if dark_side_in:
		charge_timer += delta
		
		var c := 1 - charge_timer / CHARGE_MAX
		sprite.modulate = Color(c, c, c)
		
		if charge_timer >= CHARGE_MAX:
			dark.show()
	else:
		charge_timer = 0
		if not dark.visible:
			sprite.modulate = Color.white

func something_entered(body: Node) -> void:
	if body.is_in_group("darkside"):
		dark_side_in = true

func something_exited(body: Node) -> void:
	if body.is_in_group("darkside"):
		dark_side_in = false
