extends CharacterBody2D


@export var speed = 150.0
@export var acceleration = 800.0
@export var friction = 1000.0
@export var jump_velocity = -260.0
@export var gravity_scale = 1.0
@export var air_resistance = 200.0
@export var air_acceleration = 400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var buffered_jump = false

@onready var collision_shape_2d := $CollisionShape2D
@onready var animated_sprite_2d := $Graphics/AnimatedSprite2D
@onready var coyote_jump_timer := $CoyoteJumpTimer
@onready var jump_buffer_timer := $JumpBufferTimer

@onready var starting_position = global_position


func _physics_process(delta):
	handle_gravity(delta)
	handle_jump()
	
	var input_axis = Input.get_axis("move_left", "move_right")
	
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	var just_left_floor = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_floor:
		coyote_jump_timer.start()
	
	update_animations(input_axis)


func handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta


func handle_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump") or buffered_jump:
			velocity.y = jump_velocity
			buffered_jump = false
	elif not is_on_floor() and Input.is_action_just_pressed("jump"):
		buffered_jump = true
		jump_buffer_timer.start()


func handle_acceleration(input_axis, delta):
	if not is_on_floor():
		return
	if input_axis:
		velocity.x = move_toward(velocity.x, speed * input_axis, acceleration * delta)


func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): 
		return
	if input_axis:
		velocity.x = move_toward(velocity.x, speed * input_axis, air_acceleration * delta)


func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)


func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance * delta)


func update_animations(input_axis):
	if input_axis:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_jump_buffer_timer_timeout():
		buffered_jump = false
