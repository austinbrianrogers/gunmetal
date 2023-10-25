extends "res://Assets/Scenes/WorldObjects/Enemies/Target.gd"
#compile
@export var patrol_radius:float
@export var walk_speed:float
@export var wait_time_between_moves:float
@export var wait_time_between_attacks:float
@export var attacks_between_charge:int
func _ready():
	m_current_health =  health_points
	_get_timers()
	_get_origin()
	_choose_destination()
	_charge()

func _physics_process(delta):
	velocity.y += delta * Maths.Gravity
	move_and_slide()

func _process(delta):
	match m_target_state:
		E_TARGET_STATE.PATROLLING:
			if _reached_destination():
				_halt(E_TARGET_STATE.HALTED)
		E_TARGET_STATE.IDLE:
			_choose_next()
		#E_TARGET_STATE.ATTACKING:
		#E_TARGET_STATE.CHARGING:
		#E_TARGET_STATE.HIT:
		_:
			if !_animating():
				print("State Complete, moving on.")
				_choose_next()
	
	super(delta) #SUPER call must come at the end,
	#as it can override the enemy state if nothing is happening.

func _start_patrol():
	_choose_destination()
	m_target_state = E_TARGET_STATE.PATROLLING
	await m_move_timer
	_turn_around()
	print("Starting patrol")
	_go()

func _continue_patrol():
	print("On the move.")
	m_target_state = E_TARGET_STATE.PATROLLING
	await m_move_timer
	print("Continuing patrol")
	_go()
	
func _go():
	var vector = m_destination - position
	vector = vector.normalized()
	velocity.x = vector.x * walk_speed
	$AnimatedSprite2D.play("Walk")

func _halt(reason):
	print("Stopping")
	velocity.x = 0
	match reason:
		E_TARGET_STATE.HIT:
			$AnimatedSprite2D.play("Hit")
			m_target_state = E_TARGET_STATE.HIT
		#E_TARGET_STATE.HALTED:
		#E_TARGET_STATE.WAITING:
		_:	
			m_target_state = E_TARGET_STATE.WAITING
			$AnimatedSprite2D.play("Idle")
			_choose_next()

func _return_fire():
	_hide()
	_aim()

func _choose_next():
	print("Thinking")
	match m_target_state: 
		E_TARGET_STATE.PATROLLING:
			pass
		E_TARGET_STATE.ATTACKING:
			_attack()
		E_TARGET_STATE.CHARGING:
			_continue_patrol()
		#E_TARGET_STATE.IDLE:
		#E_TARGET_STATE.WAITING:
		_:
			_start_patrol()

func _attack():
	if m_current_charge <= 0:
		_charge()
	else:
		print("Fire!")
		await m_attack_timer
		$AnimatedSprite2D.play("Shoot")
		m_target_state = E_TARGET_STATE.ATTACKING
		m_current_charge -= 1

func _charge():
	print("Reloading!")
	m_target_state = E_TARGET_STATE.CHARGING
	m_current_charge = attacks_between_charge
	$AnimatedSprite2D.play("Reload")

func _hide():
	pass

func _retreat():
	pass

func _chase():
	pass

func _aim():
	m_attack_vector = m_last_hit_vector.normalized()
	if m_attack_vector.x > 0:
		if !m_left_face:
			_turn_around()
	else:
		if m_left_face:
			_turn_around()
	_attack()

func _hit(body):
	_on_body_entered(body)#super
	_halt(E_TARGET_STATE.HIT)
	_register_hit(body)
	pass

func _register_hit(body):
	m_last_hit_vector = body.linear_velocity
	_return_fire()

func _get_origin():
	m_origin = position

func _choose_destination():
	var distance
	if m_first_move:
		distance = patrol_radius  / 2
	else:
		distance = patrol_radius 

	if !m_left_face:
		distance *= -1

	_set_destination(Vector2(position.x + distance, position.y))
	m_first_move = false
	print("My Position is...", position)
	print("My Destination is.... ", m_destination)

func _set_destination(destination:Vector2):
	m_destination = destination

func _reached_destination():
	var vector = position - m_destination
	var distance = Maths.Pyth(vector.x, vector.y)
	if distance < DESTINATION_TOLERANCE:
		print("End of patrol path, turning around")
		return true
	else:
		return false

func _get_timers():
	var root = get_tree()
	m_attack_timer = root.create_timer(wait_time_between_attacks)
	m_move_timer = root.create_timer(wait_time_between_moves)

#runtime
var m_origin:Vector2
var m_first_move:bool
var m_destination:Vector2
var m_last_hit_vector:Vector2
var m_attack_vector:Vector2
var m_current_charge:int = attacks_between_charge
var m_attack_timer
var m_move_timer
#compile
const DESTINATION_TOLERANCE:int = 30 #pixels


