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
	GameManager.player = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	#useful vars
	var left = Input.is_action_pressed("move_left")
	var right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_just_pressed("jump")
	var shooting = Input.is_action_pressed("shoot")
	var floored = is_on_floor()
	m_prone = Input.is_action_pressed("prone")
	m_last_shot_timer += delta
	#attacks first
	if floored && !shooting:
		#side movement
		if right:
			_move_now(false)
		else: if left: 
			_move_now(true)
		else: if !left && !right: 
			velocity.x = 0
			m_moving = false
		#player jumped
		if  jump:
			_jump()	
		else: if m_prone:
			velocity = Vector2.ZERO
	else:
		#player jumping already
		if m_prone: velocity.y = MAX_SPEED_VERTICAL * 2
	#screen limit
	position = position.clamp(Vector2.ZERO, m_screen_bound)
	#velocity dependent sprite flip only when moving
		
	#animation handling
	if floored:
		if m_prone:
			if shooting:
				_shoot(true)
			else: 
				m_animator.play("Prone")
		else:
			if shooting:
				_shoot(false)
			else: if _is_moving():
				m_animator.play("Run")
			else: 
				m_animator.play("Default")
	else:
		_set_jump_frame()
		if right:
			_aerial_move(false)
		else: if left: 
			_aerial_move(true)
	
	_set_prone_hitbox_enabled(m_prone)

func _shoot(prone:bool):
	if prone:
		m_animator.play("ProneShooting")
	else: 
		m_animator.play("Shooting")
	
	velocity = Vector2.ZERO
	_determine_projectiles()

func _set_jump_frame():
	m_animator.play("Jump")
	if velocity.y < 0:
		m_animator.frame = 0;
	if velocity.y > 0:
		m_animator.frame = 1;
	
func _jump():
	if m_moving: 
		velocity.y = -MAX_SPEED_VERTICAL 
	else: 
		velocity.y = -MAX_SPEED_VERTICAL * 1.05

func _move_now(left:bool):
	if left:
		velocity.x = -MAX_SPEED_HORIZONTAL 
	else:
		velocity.x = MAX_SPEED_HORIZONTAL
	m_moving = true;

func _aerial_move(left:bool):
	if abs(velocity.x) != 0: #only do this if we are not already moving.
		return

	if left:
		velocity.x = -MAX_SPEED_HORIZONTAL / 6.0
	else:
		velocity.x = MAX_SPEED_HORIZONTAL / 6.0
	m_animator.play("Jump")
	
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
var m_moving = false
var m_animator
var m_standing_hitbox: CollisionShape2D
var m_prone_hitbox: CollisionShape2D
var m_last_shot_timer:float = 0
#signals
signal standing_right_shooting
signal prone_right_shooting
signal standing_left_shooting
signal prone_left_shooting
