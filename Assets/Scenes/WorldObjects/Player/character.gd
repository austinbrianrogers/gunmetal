extends CharacterBody2D

# compile time variables
@export var speed = 400
const GRAVITY = 200
const LEFT = -1
const RIGHT = 1

# runtime variables
var screen_bound
var _gravity_enabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_bound = get_viewport_rect().size
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		set_scale(Vector2(RIGHT, 1))
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		set_scale(Vector2(LEFT, 1))
		velocity.x -= 1
	if Input.is_action_pressed("crouch"):
		velocity.y += 1
	if Input.is_action_pressed("jump"):
		_gravity_enabled = true
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play("Run")
	else:
		$AnimatedSprite2D.play("Default")
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_bound)
	pass
	
func _physics_process(delta):
	if _gravity_enabled:
		velocity.y += delta * GRAVITY
		var motion = velocity * delta
		move_and_collide(motion)
	pass
	


func _on_foot_box_body_entered(body):
	print_debug(body.name + "collided with an object.")
	_gravity_enabled = false
	pass # Replace with function body.
