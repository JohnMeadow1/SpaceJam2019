extends Node2D

const CHARGE_MAX := 1.0

#onready var sprite: Sprite = $Sprite
onready var dark: Node2D = $LightScale
onready var timer: Timer = $Timer

var dark_side_in: bool
var charge_timer: float
var darkness_is_on:bool = false
onready var size_in_pixels:float = $LightScale/Light2D.texture.get_size().x * scale.x

func darken(delta: float) -> void:
	if not $AnimatedSprite.visible:
		$AnimatedSprite.frame = 0
		$AnimatedSprite.show()
	
	if darkness_is_on:
		timer.start()
		return
	
	charge_timer += delta
	
#	var c := 1 - charge_timer / CHARGE_MAX
#	sprite.modulate = Color(c, c, c)
	
	if charge_timer >= CHARGE_MAX:
		dark.show()
		darkness_is_on = true
		timer.start()
		timer.wait_time = rand_range(5,10)
		$AudioStreamPlayer2D.play()
		$AudioStreamPlayer2D2.play()

func reset():
	if darkness_is_on:
		return
	
	charge_timer = 0
#	sprite.modulate = Color.white

func dedark() -> void:
	darkness_is_on = false
	dark.hide()
#	sprite.modulate = Color.white
	charge_timer = 0
	$AudioStreamPlayer2D2.stop()

func _on_AnimatedSprite_animation_finished() -> void:
	$AnimatedSprite.hide()
