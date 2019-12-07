extends KinematicBody2D

const DISTANCE_THRESHOLD: = 3.0
const DARKSIDE_THRESHOLD: = 500.0
export var max_speed: = 300.0

var target_global_position: = Vector2.ZERO setget set_target_global_position
var velocity: = Vector2.ZERO

var _is_following: = false
var timer = 0.0
var timeout = 2.0
var can_talk = true

onready var darkside = get_tree().get_nodes_in_group("darkside").front()

func _ready() -> void:
	randomize()
	can_talk = bool(randi()%2)
	timeout = rand_range(1.0,5.0)
	set_new_target()

func _physics_process(delta: float) -> void:
	if timer < timeout:
		timer += delta
	else:
		timer = 0.0
		timeout = -1.0
		$eyes.hide()
		can_talk = bool(randi()%100<1)
		

	$eyes.position = Vector2 (rand_range(-1,1),rand_range(-1,1))
#
#	if Input.is_action_pressed("click"):
#		self.target_global_position = get_global_mouse_position()
		
	
	if global_position.distance_to(target_global_position) < DISTANCE_THRESHOLD:
		set_new_target()
	velocity = Steering.arrive_to( velocity, global_position, target_global_position, max_speed )
		
	var distance_to_edge := Vector2.ZERO
	for node in get_tree().get_nodes_in_group("light"):
		if node.darkness_is_on:
			distance_to_edge = global_position - node.global_position
			velocity += distance_to_edge.normalized() /  max(1, distance_to_edge.length() - node.size_in_pixels * 0.5 ) * max_speed * 0.1
				
	for node in get_tree().get_nodes_in_group("avoid"):
		distance_to_edge = global_position - node.global_position
		velocity += distance_to_edge.normalized() / max(1, distance_to_edge.length() - node.distance) * max_speed
	
	velocity += (global_position - darkside.global_position).normalized() / ((global_position - darkside.global_position).length() + 1.0)
	if global_position.distance_to(darkside.global_position) < DARKSIDE_THRESHOLD:
		if abs(darkside.get_node("Light2D").rotation - (global_position - darkside.global_position).angle()) < PI/4.0:
			var new_direction = (global_position - darkside.global_position).tangent() * sign (darkside.get_node("Light2D").rotation - (global_position - darkside.global_position).angle())
			run_away( new_direction + (global_position - darkside.global_position) )

			if !$neverJoin.playing && can_talk:
				$neverJoin.play()
				get_dark()
				
		
	$target.global_position = target_global_position
	velocity = move_and_slide(velocity)
	rotate_actor()
	
func get_dark():
	timeout = rand_range(2.0,3.0)
	$eyes.show()
	can_talk = false

func rotate_actor():
	var direction:int = round(((velocity.angle() + PI*1.5) / PI) * 2)
	match direction:
		1:$AnimatedSprite.play("left")
		2:$AnimatedSprite.play("up")
		3:$AnimatedSprite.play("right")
		4:$AnimatedSprite.play("down")
	
func set_new_target():
	var target = Vector2.ZERO
	var valid_target = false
	for i in 1000: 
		valid_target = true
		target = Vector2( rand_range(0, 2000), rand_range(0, 1000) )
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
	
