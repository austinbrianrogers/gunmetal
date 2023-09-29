extends CharacterBody2D

# compile time variables
const GRAVITY = 800
const LEFT = -1
const RIGHT = 1
const MAX_SPEED_HORIZONTAL = 400
const MAX_SPEED_VERTICAL = 300
const JUMP_DELAY = .5

# runtime variables
var screen_bound
var gravity_enabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_bound = get_viewport_rect().size
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	var left = Input.is_action_pressed("move_left")
	var right = Input.is_action_pressed("move_right")
	if right:
		velocity.x = MAX_SPEED_HORIZONTAL
	else: if left:
		velocity.x = -MAX_SPEED_HORIZONTAL
	else: if !left && !right:
		velocity.x = 0
	if Input.is_action_pressed("crouch"):
		velocity.x = 0
	if Input.is_action_pressed("jump") && is_on_floor():
		velocity.y = -MAX_SPEED_VERTICAL
	
	if velocity.length() > 0 && is_on_floor():
		$AnimatedSprite2D.play("Run")
	else: if is_on_floor():
		$AnimatedSprite2D.play("Default")
	else: 
		$AnimatedSprite2D.play("Jump")
		
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		
	position = position.clamp(Vector2.ZERO, screen_bound)
	pass
	
func _physics_process(delta):
	if gravity_enabled:
		velocity.y += delta * GRAVITY
		var motion = velocity * delta
		move_and_slide()
	pass
