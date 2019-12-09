extends KinematicBody2D

const DISTANCE_THRESHOLD: = 30.0
const DARKSIDE_THRESHOLD: = 500.0
export var max_speed: = 300.0

const MAX_DARKNESS = 100.0

var frozen

var target_global_position: = Vector2.ZERO setget set_target_global_position
var velocity: = Vector2.ZERO

var _is_following: = false
var timer = 0.0
var timeout = 2.0
var can_talk = true

var darkness = 0.0
var lifes = 3

onready var darkside = get_tree().get_nodes_in_group("darkside").front()

func _ready() -> void:
	randomize()
	can_talk = bool(randi()%2)
	timeout = rand_range(1.0,5.0)
	set_new_target()
	$Force_push/Tween.connect("tween_all_completed", $Force_push, "hide")

func _physics_process(delta: float) -> void:
	if frozen: return
	
	if timer < timeout:
		timer += delta
	else:
		timer = 0.0
		timeout = -1.0
		$eyes.hide()
		can_talk = bool(randi()%100<1)
		
	if darkness>0 and lifes > 0:
		darkness = max (0, darkness - delta *10)
	$eyes.position = Vector2 (rand_range(-1,1),rand_range(-1,1))
#
#	if Input.is_action_pressed("click"):
#		self.target_global_position = get_global_mouse_position()
		
	
	if global_position.distance_to(target_global_position) < DISTANCE_THRESHOLD:
		if lifes:

			set_new_target()
	velocity = Steering.arrive_to( velocity, global_position, target_global_position, max_speed )
		
	var distance_to_edge := Vector2.ZERO
#	for node in get_tree().get_nodes_in_group("light"):
#		if node.darkness_is_on:
#			distance_to_edge = global_position - node.global_position
#			velocity += distance_to_edge.normalized() /  max(1, distance_to_edge.length() - node.size_in_pixels * 0.5 ) * max_speed * 0.1
#
	for node in get_tree().get_nodes_in_group("avoid"):
		if lifes == 0 and node.is_in_group("hax"):
			continue
		
		distance_to_edge = global_position - node.global_position
		if distance_to_edge.length() - node.distance < 0:
			if lifes:
				velocity = move_and_slide( distance_to_edge )
				set_new_target()
			velocity += (distance_to_edge.normalized() * abs( distance_to_edge.length() - node.distance)) 
#			velocity += (distance_to_edge.normalized() / max(1, distance_to_edge.length() - node.distance)) * max_speed
		
	if darkside.is_flashlight_on and lifes > 0:
	#	velocity += (global_position - darkside.get_node("Light2D").global_position).normalized() / ((global_position - darkside.get_node("Light2D").global_position).length() + 1.0)
		if global_position.distance_to(darkside.get_node("Light2D").global_position) < DARKSIDE_THRESHOLD:
			if abs(darkside.get_node("Light2D").rotation - (global_position - darkside.get_node("Light2D").global_position).angle()) < PI/4.0:
				var new_direction = (global_position - darkside.global_position).tangent() * sign (darkside.get_node("Light2D").rotation - (global_position - darkside.get_node("Light2D").global_position).angle())
				run_away( new_direction + (global_position - darkside.get_node("Light2D").global_position) )
				darkness += 1
				if !$neverJoin.playing && darkness >MAX_DARKNESS :
					lifes -= 1
					if lifes == 0:
						$AnimatedSprite.play("darkening")
						max_speed = 150.0
						frozen = true
						get_tree().get_root().get_node("Game").darkside_count += 1
						darkside.get_node("AudioStreamPlayer2D6").play()
						set_target_global_position(get_tree().get_nodes_in_group("hax").front().global_position)
						return
					
					$ForceSFX.play()
					darkness = 0
					$neverJoin.play()
					get_dark()
					darkside.get_push(darkside.get_node("Light2D").global_position - global_position)
					
					var dir: Vector2 = (darkside.global_position - global_position).normalized()
					$Force_push.show()
					$Force_push.frame = 0
					$Force_push.rotation = dir.angle()
					$Force_push/Tween.interpolate_property($Force_push, "global_position", global_position, global_position + dir * 700, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
					$Force_push/Tween.start()
					
				
		
	$target.global_position = target_global_position
	velocity = move_and_slide(velocity)
	rotate_actor()
	
	$AnimatedSprite.material.set_shader_param("power", darkness / MAX_DARKNESS)
	
func get_dark():
	timeout = rand_range(2.0,3.0)
	$eyes.show()
	can_talk = false
	
func rotate_actor():
	if lifes == 0:
		$AnimatedSprite.play("run_away")
	else:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x < 0:
				$AnimatedSprite.play("left")
			else:
				$AnimatedSprite.play("right")
		else:
			if velocity.y < 0:
				$AnimatedSprite.play("up")
			else:
				$AnimatedSprite.play("down")
	
func set_new_target():
	var target = Vector2.ZERO
	var valid_target = false
	for i in 1000: 
		valid_target = true
		target = Vector2( rand_range(0, 2500), rand_range(0, 2000) )
		for node in get_tree().get_nodes_in_group("light"):
			if node.darkness_is_on:
				if (node.global_position - target).length() <= node.size_in_pixels:
					valid_target = false
		for node in get_tree().get_nodes_in_group("avoid"):
			if (node.global_position - target).length() <= node.distance:
				valid_target = false
		if valid_target:
			break
					
	set_target_global_position( target )
	
func run_away(value: Vector2) -> void:
	set_target_global_position( global_position + value.normalized() * 100)
	
func set_target_global_position(value: Vector2) -> void:
	target_global_position = value
	


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "darkening":
		frozen = false

