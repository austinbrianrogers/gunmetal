extends "res://Assets/Scenes/WorldObjects/Enemies/target.gd"
#compile
@export var patrol_radius:float
@export var walk_speed:float
@export var wait_time_between_moves:float
@export var wait_time_between_attacks:float
@export var attacks_between_charge:int
@export var patrol_start_left:bool
@export var search_radius:float
func _ready():
	m_current_health =  health_points
	m_original_raycast_distance = $RayCast2D.scale.x
	var face = 1
	if patrol_start_left:
		face *= -1
	var initial_vector = Vector2(patrol_radius * face, 0)
	_set_destination_update_origin(position + initial_vector)
	_set_timers()
	_charge()

func _physics_process(delta):
	velocity.y += delta * Maths.Gravity
	move_and_slide()
	super(delta)

func _process(delta):
	match m_target_state:
		E_TARGET_STATE.PATROLLING:
			if _reached_destination():
				_halt(E_TARGET_STATE.HALTED)
			if _face_colliding_with_walls():
				_set_face_detection_enabled(false)
				_halt(E_TARGET_STATE.HALTED)
		#E_TARGET_STATE.ATTACKING:
		#E_TARGET_STATE.CHARGING:
		#E_TARGET_STATE.HIT:
		_:
			if !_animating():
				print("State Complete, moving on.")
				_choose_next()
	super(delta) #SUPER call must come at the end,
	#as it can override the enemy state if nothing is happening.

func _nudge(left:bool):
	var dir = 1;
	if left: dir = -1
	position += ($CollisionShape2D.get_node("Node2D").transform.width) * dir

func _start_patrol():
	_choose_destination()
	m_target_state = E_TARGET_STATE.PATROLLING
	m_move_timer.start()
	print("Starting patrol")

func _continue_patrol():
	print("On the move.")
	m_target_state = E_TARGET_STATE.PATROLLING
	m_move_timer.start()
	print("Continuing patrol")
	
func _go():
	var vector = m_destination - position
	vector = vector.normalized()
	velocity.x = vector.x * walk_speed
	$AnimatedSprite2D.play("Walk")
	$RayCast2D.enabled = true

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
			_start_attack()
		E_TARGET_STATE.CHARGING:
			_continue_patrol()
		#E_TARGET_STATE.HIT:
		#	_aim()
		#E_TARGET_STATE.IDLE:
		#E_TARGET_STATE.WAITING:
		_:
			_start_patrol()

func _start_attack():
	if m_current_charge <= 0:
		_charge()
	m_attack_timer.start()

func _attack():
	m_target_state = E_TARGET_STATE.ATTACKING
	print("Fire!")
	$AnimatedSprite2D.play("Shoot")
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
	
	_search()

func _hit(body):
	_on_body_entered(body)#super
	_register_hit(body)

func _register_hit(body):
	_halt(E_TARGET_STATE.HIT)
	m_move_timer.stop()
	m_attack_timer.stop()
	m_last_hit_vector = body.linear_velocity
	_add_to_health(-1)

func _update_origin():
	m_origin = position

func _choose_destination():
	var face = 1
	if (_is_left_of(m_origin)):
		face = -1
	_set_destination_update_origin(Vector2(position + Vector2(patrol_radius * face, 0)))

func _set_destination_update_origin(destination:Vector2):
	m_destination = destination
	_update_origin()

func _reached_destination():
	var vector = position - m_destination
	var distance = Maths.Pyth(vector.x, vector.y)
	if distance < DESTINATION_TOLERANCE:
		print("End of patrol path, turning around")
		return true
	else:
		return false

func _destined_left():
	return (m_destination - position).x < 0

func _set_face_detection_enabled(enabled:bool):
	$RayCast2D.enabled = enabled

func _is_left_of(pos:Vector2):
	return (pos - position).x < 0

func _set_timers():
	m_move_timer = Timer.new()
	m_move_timer.autostart = false
	add_child(m_move_timer)
	m_move_timer.wait_time = wait_time_between_moves
	m_move_timer.connect("timeout", Callable(self, "_move_timer_complete"))

	m_attack_timer = Timer.new()
	m_attack_timer.autostart = false
	add_child(m_attack_timer)
	m_attack_timer.wait_time = wait_time_between_moves
	m_attack_timer.connect("timeout", Callable(self, "_attack_timer_complete"))

func _attack_timer_complete():
	_attack()

func _move_timer_complete():
	_go()

func _set_raycast_length(length:float):
	$RayCast2D.scale.x = length

func _search():
	_set_raycast_length(search_radius)
	_scan_for_player()

func _end_search():
	_set_raycast_length(m_original_raycast_distance)

func _target_found():
	_attack()

func _target_lost():
	_start_patrol()

func _scan_for_player():
	pass

func _face_colliding_with_walls():
	pass

func _search_colliding_with_player():
	pass

#runtime
var m_origin:Vector2
var m_destination:Vector2
var m_last_hit_vector:Vector2
var m_attack_vector:Vector2
var m_current_charge:int = attacks_between_charge
var m_attack_timer
var m_move_timer
var m_original_raycast_distance
#compile
const DESTINATION_TOLERANCE:int = 30 #pixels


