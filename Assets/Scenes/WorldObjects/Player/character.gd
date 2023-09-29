extends CharacterBody2D

# compile time variables
const GRAVITY = 1000
const LEFT = -1
const RIGHT = 1
const MAX_SPEED_HORIZONTAL = 400
const MAX_SPEED_VERTICAL = 550
const JUMP_DELAY = .5

# runtime variables
var screen_bound
var gravity_enabled = true
var prone = false
var hitboxStateProne = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_bound = get_viewport_rect().size
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	#useful vars
	var left = Input.is_action_pressed("move_left")
	var right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_just_pressed("jump")
	var floored = is_on_floor()
	var moving = false
	prone = Input.is_action_pressed("prone")
	#velocity first
	if floored:
		#side movement
		if right:
			velocity.x = MAX_SPEED_HORIZONTAL
			moving = true
		else: if left: 
			velocity.x = -MAX_SPEED_HORIZONTAL 
			moving = true
		else: if !left && !right: 
			velocity.x = 0
		#player jumped
		if  jump:
			if moving: velocity.y = -MAX_SPEED_VERTICAL 
			else: velocity.y = -MAX_SPEED_VERTICAL * 1.2		
		else: if prone:
			velocity = Vector2.ZERO
			_change_height_to_prone(true)
	else:
		#player jumping already
		if prone: velocity.y = MAX_SPEED_VERTICAL * 2
	#screen limit
	position = position.clamp(Vector2.ZERO, screen_bound)
	#velocity dependent sprite flip
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	#animation handling
	if floored && prone:
		$AnimatedSprite2D.play("Prone")
		$AnimatedSprite2D.stop();
		pass
	else: if moving && floored:
		$AnimatedSprite2D.play("Run")
	else: if floored:
		$AnimatedSprite2D.play("Default")
	else: 
		$AnimatedSprite2D.play("Jump")
		
	if !prone:
		_change_height_to_prone(false)	
	pass
	
func _physics_process(delta):
	if gravity_enabled:
		velocity.y += delta * GRAVITY
		var motion = velocity * delta
		move_and_slide()
	pass
	
func _change_height_to_prone(enabled):
	if enabled == hitboxStateProne:
		pass
	else:
		if enabled:
			$CollisionShape2D.global_rotation_degrees = 90
		else:
			$CollisionShape2D.global_rotation_degrees = 0
			position.y -= 1 #give him a small bump to stand upright
	hitboxStateProne = enabled
	pass

