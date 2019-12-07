extends KinematicBody2D

const MAX_DISTANCE := 400.0
const MAX_DISTANCE_SQ := MAX_DISTANCE * MAX_DISTANCE

onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var audio2: AudioStreamPlayer2D = $AudioStreamPlayer2D2

var darkning: Node2D
var target: Node2D

const MAX_STAMINA = 3.0
var stamina := MAX_STAMINA
var got_pushed := false
var pushed_force = Vector2()
var is_flashlight_on := false

func _process(delta: float) -> void:
	$Light2D.rotation = (get_global_mouse_position() - $Light2D.global_position).angle()
	
	var move: Vector2
	move.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	if move.length() > 0:
		var direction = int(round(((move.angle() + PI) / PI) * 2))
		match direction:
			1:$AnimatedSprite.play("up")
			2:$AnimatedSprite.play("right")
			3:$AnimatedSprite.play("down")
			4:$AnimatedSprite.play("left")
	else:
		$AnimatedSprite.play("idle")
	
	
	if got_pushed:
		move_and_slide(move.normalized() * 200 + pushed_force)
		pushed_force *= 0.9
		if pushed_force.length_squared() <10:
			got_pushed = false
	else:
		move_and_slide(move.normalized() * 200)
	
	
	if darkning:
		darkning.from = $DarkningSource.global_position
		target.darken(delta)
	
	if Input.is_action_pressed("click") or Input.is_action_pressed("unlimited_power"):
		stamina = max(stamina - delta, 0)
	else:
		stamina = min(stamina + delta * 2, MAX_STAMINA)
	$AnimatedSprite.material.set_shader_param("power", stamina / MAX_STAMINA);
	is_flashlight_on = Input.is_action_pressed("click") and stamina > 0
	$Light2D.visible = is_flashlight_on
	if stamina == 0 and darkning:
		remove_dark()
	
		
func get_push(direction) -> void:
	got_pushed = true
	pushed_force = direction * 5
	
	if !$AudioStreamPlayer2D4.playing:
		if randi() % 3 != 0:
			return
		
		$AudioStreamPlayer2D4.stream = [
			preload("res://sounds/goodHateFlow.wav"),
			preload("res://sounds/good.wav")
		][randi() % 2]
		$AudioStreamPlayer2D4.play()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.is_action("unlimited_power") and not darkning:
			var lantern: Node2D
			var min_dist := MAX_DISTANCE_SQ
			
			for l in get_tree().get_nodes_in_group("light"):
				var dist := global_position.distance_squared_to(l.global_position)
				if dist < min_dist:
					lantern = l
					min_dist = dist
			
			if lantern:
				target = lantern
				darkning = preload("res://Darkning.tscn").instance()
				darkning.from = $DarkningSource.global_position
				darkning.to = lantern.global_position
				get_parent().add_child(darkning)
				audio.play()
				if randi() % 3 == 0:
					audio2.play()
		
		if not event.pressed and event.is_action("unlimited_power") and darkning:
			remove_dark()
		
		if event.pressed and event.is_action("click"):
			play3()

func remove_dark():
	darkning.queue_free()
	target.reset()
	darkning = null
	target = null
	audio.stop()

func play3():
	if !$AudioStreamPlayer2D3.playing:
		if randi() % 3 != 0:
			return
		
		$AudioStreamPlayer2D3.stream = [
			preload("res://sounds/somethingComplete.wav"),
			preload("res://sounds/somethingDarkSide.wav")
		][randi() % 2]
		$AudioStreamPlayer2D3.play()

func the_sith():
	$AudioStreamPlayer2D5.play()
