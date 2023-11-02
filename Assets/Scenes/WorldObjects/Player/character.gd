extends "res://Assets/Scenes/WorldObjects/Enemies/target.gd"
# compile time variables
const MAX_SPEED_HORIZONTAL = 400
const MAX_SPEED_VERTICAL = 550
const JUMP_DELAY = .5
#Character node children
const STANDING_HITBOX_INDEX = 0
const PRONE_HITBOX_INDEX = 1
const FIRE_RATE:float = .1

# Called when the node enters the scene tree for the first time.
func _ready():
	m_screen_bound = get_viewport_rect().size
	m_animator = $Control.get_node("AnimatedSprite2D")
	m_standing_hitbox = get_child(STANDING_HITBOX_INDEX) as CollisionShape2D
	m_prone_hitbox = get_child(PRONE_HITBOX_INDEX) as CollisionShape2D
	m_last_shot_timer = FIRE_RATE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	#useful vars
	var left = Input.is_action_pressed("move_left")
	var right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_just_pressed("jump")
	var shooting = Input.is_action_pressed("shoot")
	var floored = is_on_floor()
	var moving = false
	m_prone = Input.is_action_pressed("prone")
	m_last_shot_timer += delta
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
		else: if m_prone:
				velocity = Vector2.ZERO
	else:
		#player jumping already
		if m_prone: velocity.y = MAX_SPEED_VERTICAL * 2
	#screen limit
	position = position.clamp(Vector2.ZERO, m_screen_bound)
	#velocity dependent sprite flip only when moving
		
	#animation handling
	if floored && m_prone:
		if shooting:
			m_animator.play("ProneShooting")
			velocity = Vector2.ZERO
		else: 
			m_animator.play("Prone")
		pass
	else: if moving && floored:
		m_animator.play("Run")
	else: if floored:
		if !shooting:
			m_animator.play("Default")
		else:
			m_animator.play("Shooting")
			velocity = Vector2.ZERO
	else: 
		m_animator.play("Jump")
		
	_set_prone_hitbox_enabled(m_prone)
	if shooting && floored: _determine_projectiles()
	
func _physics_process(delta):
	if m_gravity_enabled:
		velocity.y += delta * Maths.Gravity
		move_and_slide()
	super(delta)
	
func _set_prone_hitbox_enabled(enabled:bool):
	(m_standing_hitbox as CollisionShape2D).set_disabled(enabled)
	(m_prone_hitbox as CollisionShape2D).set_disabled(!enabled)
	m_hitbox_state_prone = enabled

func _determine_projectiles():
	if(m_last_shot_timer > FIRE_RATE): 
		m_last_shot_timer = 0
		if m_hitbox_state_prone:
			if m_left_face:
				prone_left_shooting.emit()
			else:
				prone_right_shooting.emit()
		else:
			if m_left_face:
				standing_left_shooting.emit()
			else:
				standing_right_shooting.emit()

		if m_left_face: print("shoot left")
		if !m_left_face: print("shoot right")
	
# runtime variables
var m_screen_bound
var m_gravity_enabled = true
var m_prone = false
var m_hitbox_state_prone = false
var m_animator
var m_standing_hitbox: CollisionShape2D
var m_prone_hitbox: CollisionShape2D
var m_last_shot_timer:float = 0
#signals
signal standing_right_shooting
signal prone_right_shooting
signal standing_left_shooting
signal prone_left_shooting
