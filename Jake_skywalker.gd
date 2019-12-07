extends KinematicBody2D

const DISTANCE_THRESHOLD: = 3.0
const DARKSIDE_THRESHOLD: = 300.0
export var max_speed: = 200.0

var target_global_position: = Vector2.ZERO setget set_target_global_position
var velocity: = Vector2.ZERO

var _is_following: = false
var timer = 0.0
var timeout = 2.0

onready var darkside = get_tree().get_nodes_in_group("darkside").front()

func _ready() -> void:
	randomize()
	set_new_target()

func _physics_process(delta: float) -> void:
	if timer < 2.0:
		timer += delta
	else:
		timer = 0.0
		timeout = rand_range(1.5,2.5)
		set_new_target()
		
	if Input.is_action_pressed("click"):
		self.target_global_position = get_global_mouse_position()
		
	if global_position.distance_to(target_global_position) < DISTANCE_THRESHOLD:
		set_new_target()
		
	velocity = Steering.arrive_to( velocity, global_position, target_global_position, max_speed )
	for node in get_tree().get_nodes_in_group("light"):
		if node.darkness_is_on:
			if (node.global_position - (global_position+velocity)).length() <= node.size_in_pixels:
				run_away(global_position - node.global_position)
			
			
	if global_position.distance_to(darkside.global_position) < DARKSIDE_THRESHOLD:
		run_away( global_position + (global_position - darkside.global_position) )
		if !$neverJoin.playing:
			$neverJoin.play()
		
	$target.global_position = target_global_position
	velocity = move_and_slide(velocity)
	rotate_actor()
	
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
		target = Vector2( rand_range(-300, 300), rand_range(-300, 300) )
		for node in get_tree().get_nodes_in_group("light"):
			if node.darkness_is_on:
				if (node.global_position - (global_position+target)).length() <= node.size_in_pixels:
					valid_target = false
		if valid_target:
			break
					
	set_target_global_position( global_position + target )
	
func run_away(value: Vector2) -> void:
	set_target_global_position( global_position + value.normalized() * max_speed)
	
func set_target_global_position(value: Vector2) -> void:
	target_global_position = value
	
