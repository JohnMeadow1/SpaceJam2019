extends KinematicBody2D

const DISTANCE_THRESHOLD: = 3.0
export var max_speed: = 200.0

var target_global_position: = Vector2.ZERO setget set_target_global_position
var velocity: = Vector2.ZERO

var _is_following: = false
var timer = 0.0

func _ready() -> void:
	set_new_target()

func _physics_process(delta: float) -> void:
	if timer < 2.0:
		timer += delta
	else:
		timer = 0.0
		set_new_target()
		
	if Input.is_action_pressed("click"):
		self.target_global_position = get_global_mouse_position()
	if global_position.distance_to(target_global_position) < DISTANCE_THRESHOLD:
		set_new_target()
	velocity = Steering.arrive_to(
		velocity,
		global_position,
		target_global_position,
		max_speed
	)
	velocity = move_and_slide(velocity)
	rotate_actor()
	
func rotate_actor():
	pass 
	
func set_new_target():
	var target = Vector2(rand_range(0, 500),rand_range(0, 500))
	set_target_global_position(target)
	
func set_target_global_position(value: Vector2) -> void:
	target_global_position = value
	set_physics_process(true)
