extends CharacterBody2D
# compile time variables
const GRAVITY = 1000
const LEFT = -1
const RIGHT = 1
const MAX_SPEED_HORIZONTAL = 400
const MAX_SPEED_VERTICAL = 550
const JUMP_DELAY = .5

# Called when the node enters the scene tree for the first time.
func _ready():
	_screen_bound = get_viewport_rect().size
	_animator = $Control.get_node("AnimatedSprite2D")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	#useful vars
	var left = Input.is_action_pressed("move_left")
	var right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_just_pressed("jump")
	var shooting = Input.is_action_pressed("shoot")
	var floored = is_on_floor()
	var moving = false
	_prone = Input.is_action_pressed("prone")
	#attacks first
	if floored && !shooting:
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
			if moving: 
				velocity.y = -MAX_SPEED_VERTICAL 
			else: 
				velocity.y = -MAX_SPEED_VERTICAL * 1.2		
		else: if _prone:
				velocity = Vector2.ZERO
				_change_height_to_prone(true)
	else:
		#player jumping already
		if _prone: velocity.y = MAX_SPEED_VERTICAL * 2
	#screen limit
	position = position.clamp(Vector2.ZERO, _screen_bound)
	#velocity dependent sprite flip
	if velocity.x < 0:
		_animator.flip_h = true
	if velocity.x > 0:
		_animator.flip_h = false
	#animation handling
	if floored && _prone:
		_animator.play("Prone")
		_animator.stop()
		if shooting:
			_animator.play("ProneShooting")
		pass
	else: if moving && floored:
		_animator.play("Run")
	else: if floored:
		if !shooting:
			_animator.play("Default")
		else:
			_animator.play("Shooting")
	else: 
		_animator.play("Jump")
		
	if !_prone:
		_change_height_to_prone(false)	
	pass
	
func _physics_process(delta):
	if _gravity_enabled:
		velocity.y += delta * GRAVITY
		var motion = velocity * delta
		move_and_slide()
	pass
	
func _change_height_to_prone(enabled):
	if enabled == _hitboxStateProne:
		pass
	else:
		if enabled:
			$CollisionShape2D.global_rotation_degrees = 90
		else:
			$CollisionShape2D.global_rotation_degrees = 0
			position.y -= 1 #give him a small bump to stand upright
	_hitboxStateProne = enabled
	pass
	
# runtime variables
var _screen_bound
var _gravity_enabled = true
var _prone = false
var _hitboxStateProne = false
var _animator;

