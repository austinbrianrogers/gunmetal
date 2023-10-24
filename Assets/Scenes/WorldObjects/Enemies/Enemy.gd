extends "res://Assets/Scenes/WorldObjects/Enemies/Target.gd"
#compile
@export var patrol_radius:float
@export var walk_speed:float
@export var wait_time_between_moves:float
@export var wait_time_between_attacks:float
@export var attacks_between_charge:int
func _ready():
	super()
	m_target_state = E_TARGET_STATE.IDLE
	#_set_sleeping(false)
	_get_origin()
	_wait_and_choose_next()

func _physics_process(delta):
	velocity.y += delta * Maths.Gravity
	move_and_slide()

func _process(delta):
	super(delta)
	match m_target_state:
		E_TARGET_STATE.HIT:
			if !$AnimatedSprite2D.is_playing():
				_wait_and_choose_next()
		E_TARGET_STATE.PATROLLING:
			if _reached_destination():
				_halt(E_TARGET_STATE.HALTED)
		E_TARGET_STATE.ATTACKING:
			if !$AnimatedSprite2D.is_playing():
				if  m_current_shots >= attacks_between_charge:
					_charge()
				else:
					$AnimatedSprite2D.play("Idle")
					_wait_and_choose_next()
		E_TARGET_STATE.IDLE:
			_wait_and_choose_next()
		_:
			pass

func _start_patrol():
	m_target_state = E_TARGET_STATE.PATROLLING
	await get_tree().create_timer(wait_time_between_moves).timeout
	_turn_around()
	print("Starting patrol")
	var vector = m_destination - position
	vector = vector.normalized()
	print("Direction is ", vector)
	velocity.x = vector.x * walk_speed
	print("Patrolling with velocity ", velocity)
	$AnimatedSprite2D.play("Walk")

func _halt(reason):
	print("Stopping")
	velocity.x = 0
	match reason:
		E_TARGET_STATE.HIT:
			$AnimatedSprite2D.play("Hit")
		E_TARGET_STATE.HALTED:
			m_target_state = E_TARGET_STATE.WAITING
			$AnimatedSprite2D.play("Idle")
			_wait_and_choose_next()
		_:	
			m_target_state = E_TARGET_STATE.WAITING
			$AnimatedSprite2D.play("Idle")
			_wait_and_choose_next()

func _return_fire():
	_hide()
	_aim()

func _wait_and_choose_next():
	print("Thinking")
	match m_target_state: 
		E_TARGET_STATE.PATROLLING:
			_choose_destination()
			_start_patrol()
		E_TARGET_STATE.ATTACKING:
			_attack()
		E_TARGET_STATE.IDLE:
			_start_patrol()
			pass

func _attack():
	print("Fire!")
	await get_tree().create_timer(wait_time_between_attacks).timeout
	$AnimatedSprite2D.play("Shoot")
	m_target_state = E_TARGET_STATE.ATTACKING
	m_current_shots += 1
	pass

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

func _charge():
	m_target_state = E_TARGET_STATE.CHARGING
	$AnimatedSprite2D.play("Reload")


func _hit(body):
	_halt(E_TARGET_STATE.HIT)
	_register_hit(body)
	_on_body_entered(body)
	pass

func _register_hit(body):
	m_last_hit_vector = body.linear_velocity
	_return_fire()

func _get_origin():
	m_origin = position

func _choose_destination():
	var distance
	if m_first_move:
		distance = patrol_radius / 2
	else:
		distance = patrol_radius

	if !m_left_face:
		distance *= -1

	_set_destination(Vector2(position.x + distance, position.y))
	m_first_move = false
	print("Destination is.... ", m_destination)

func _set_destination(destination:Vector2):
	m_destination = destination

func _reached_destination():
	var vector = m_destination - position
	if(Maths.Pyth(vector.x, vector.y)) < DESTINATION_TOLERANCE:
		print("End of patrol path, turning around")
		return true
	else:
		return false
#runtime
var m_origin:Vector2
var m_first_move:bool
var m_destination:Vector2
var m_last_hit_vector:Vector2
var m_attack_vector:Vector2
var m_current_shots:int = 0
#compile
const DESTINATION_TOLERANCE:int = 1


