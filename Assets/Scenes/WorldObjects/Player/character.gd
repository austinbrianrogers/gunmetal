extends CharacterBody2D
# compile time variables
const GRAVITY = 1000
const LEFT = -1
const RIGHT = 1
const MAX_SPEED_HORIZONTAL = 400
const MAX_SPEED_VERTICAL = 550
const JUMP_DELAY = .5
#Character node children
const STANDING_HITBOX_INDEX = 0
const PRONE_HITBOX_INDEX = 1
const FIRE_RATE:float = .1

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_bound = get_viewport_rect().size
	animator = $Control.get_node("AnimatedSprite2D")
	standing_hitbox = get_child(STANDING_HITBOX_INDEX) as CollisionShape2D
	prone_hitbox = get_child(PRONE_HITBOX_INDEX) as CollisionShape2D
	last_shot_timer = FIRE_RATE
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
	prone = Input.is_action_pressed("prone")
	last_shot_timer += delta
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
		else: if prone:
				velocity = Vector2.ZERO
	else:
		#player jumping already
		if prone: velocity.y = MAX_SPEED_VERTICAL * 2
	#screen limit
	position = position.clamp(Vector2.ZERO, screen_bound)
	#velocity dependent sprite flip only when moving
	if _is_moving():
		_flip_for_direction(_is_moving_left())
	#animation handling
	if floored && prone:
		if shooting:
			animator.play("ProneShooting")
			velocity = Vector2.ZERO
		else: 
			animator.play("Prone")
		pass
	else: if moving && floored:
		animator.play("Run")
	else: if floored:
		if !shooting:
			animator.play("Default")
		else:
			animator.play("Shooting")
			velocity = Vector2.ZERO
	else: 
		animator.play("Jump")
		
	_set_prone_hitbox_enabled(prone)
	if shooting && floored: _determine_projectiles()
	
func _physics_process(delta):
	if gravity_enabled:
		velocity.y += delta * GRAVITY
		var motion = velocity * delta
		move_and_slide()
	pass
	
func _set_prone_hitbox_enabled(enabled:bool):
	(standing_hitbox as CollisionShape2D).set_disabled(enabled)
	(prone_hitbox as CollisionShape2D).set_disabled(!enabled)
	hitbox_state_prone = enabled
	pass

func _flip_for_direction(left:bool):
	if left && !left_face:
		left_face = true
		$Control.scale = Vector2(LEFT, 1)
	else: if !left && left_face:
		left_face = false
		$Control.scale = Vector2(RIGHT, 1)
	pass

func _determine_projectiles():
	if(last_shot_timer > FIRE_RATE): 
		last_shot_timer = 0
		if hitbox_state_prone:
			if left_face:
				prone_left_shooting.emit()
			else:
				prone_right_shooting.emit()
		else:
			if left_face:
				standing_left_shooting.emit()
			else:
				standing_right_shooting.emit()

		if left_face: print("shoot left")
		if !left_face: print("shoot right")
		pass

func _is_moving():
	return velocity.x != 0

func _is_moving_left():
	return velocity.x < 0

func _is_moving_right():
	return velocity.x > 0
	
# runtime variables
var screen_bound
var gravity_enabled = true
var prone = false
var hitbox_state_prone = false
var animator
var left_face = false
var standing_hitbox: CollisionShape2D
var prone_hitbox: CollisionShape2D
var last_shot_timer:float = 0
#signals
signal standing_right_shooting
signal prone_right_shooting
signal standing_left_shooting
signal prone_left_shooting
