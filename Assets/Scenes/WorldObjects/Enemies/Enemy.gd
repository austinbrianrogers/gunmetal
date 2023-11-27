extends "res://Assets/Scenes/WorldObjects/Enemies/target.gd"
#compile
@export var patrol_radius:float
@export var walk_speed:float
@export var wait_time_between_moves:float
@export var wait_time_between_attacks:float
@export var attacks_between_charge:int
@export var patrol_start_left:bool
@export var search_radius:float
@export var vertical_search_tolerance:float
func _ready():
	m_current_health =  health_points
	$PlayerSearch.scale.x = search_radius
	var face = -1 if patrol_start_left else 1
	var initial_vector = Vector2(patrol_radius * face, 0)
	_set_destination_update_origin(position + initial_vector)
	_set_timers()
	_charge()

func _physics_process(delta):
	velocity.y += delta * Maths.Gravity
	move_and_slide()

func _process(delta):
	match m_target_state:
		E_TARGET_STATE.PATROLLING:
			_correct_face()
			if _reached_destination():
				_halt(E_TARGET_STATE.HALTED)
			if $CollisionCast.is_colliding():
				_halt(E_TARGET_STATE.HALTED)
			else: if _find_player():
				_halt(E_TARGET_STATE.ATTACKING)
		E_TARGET_STATE.ATTACKING:
			if !_animating():
				_choose_next()
				return
		#E_TARGET_STATE.MELEE:
		#E_TARGET_STATE.CHARGING:
		#E_TARGET_STATE.HIT:
		_:
			if !_animating():
				_choose_next()
				return
			if $CollisionCast.is_colliding():
				_halt(E_TARGET_STATE.HALTED)
	
	super(delta) #SUPER call must come at the end,
	#as it can override the enemy state if nothing is happening.

func _nudge(left:bool):
	var dir = 1;
	if left: dir = -1
	position += ($CollisionShape2D.get_node("Node2D").transform.width) * dir

func _start_patrol():
	print("start patrol")
	_choose_destination()
	m_target_state = E_TARGET_STATE.PATROLLING
	m_move_timer.start()

func _continue_patrol():
	print("continue patrol")
	m_target_state = E_TARGET_STATE.PATROLLING
	m_move_timer.start()
	
func _go():
	print("go")
	var vector = m_destination - position
	var vector_normal = vector.normalized()
	_correct_face_to(vector)
	velocity.x = vector_normal.x * walk_speed
	$AnimatedSprite2D.play("Walk")
	m_move_timer.stop()
	_set_face_detection_enabled(true)

func _halt(reason):
	print("halt")
	_set_face_detection_enabled(false)
	_idle()
	match reason:
		E_TARGET_STATE.HIT:
			$AnimatedSprite2D.play("Hit")
			m_target_state = E_TARGET_STATE.HIT
		E_TARGET_STATE.ATTACKING:
			m_target_state = E_TARGET_STATE.ATTACKING
			_return_fire()
		#E_TARGET_STATE.HALTED:
		#E_TARGET_STATE.WAITING:
		_:	
			m_target_state = E_TARGET_STATE.WAITING
			$AnimatedSprite2D.play("Idle")
			_choose_next()

func _return_fire():
	_idle()
	m_move_timer.stop()
	_hide()
	_aim()

func _choose_next():
	print("choose")
	m_move_timer.stop()
	m_attack_timer.stop()
	#At this point, the character should be doing NOTHING and therefore the timers need to stop.
	match m_target_state: 
		E_TARGET_STATE.PATROLLING:
			pass
		E_TARGET_STATE.CHARGING:
			_continue_patrol()
		E_TARGET_STATE.MELEE:
			_continue_patrol()
		E_TARGET_STATE.HIT:
			_return_fire()
		#E_TARGET_STATE.ATTACKING:
		#E_TARGET_STATE.IDLE:
		#E_TARGET_STATE.WAITING:
		_:
			_start_patrol()

func _start_attack():
	_set_face_detection_enabled(true)
	print("start attack")
	if _can_melee():
		_melee_attack()
		m_target_state = E_TARGET_STATE.MELEE
		return

	if m_current_charge <= 0:
		_charge()
	else:
		m_target_state = E_TARGET_STATE.ATTACKING
		m_attack_timer.start()

func _attack():
	_set_face_detection_enabled(false)
	print("fire!")
	$AnimatedSprite2D.play("Shoot")
	m_current_charge -= 1
	m_attack_timer.stop()

func _charge():
	_set_face_detection_enabled(false)
	print("reload!")
	m_target_state = E_TARGET_STATE.CHARGING
	m_current_charge = attacks_between_charge
	$AnimatedSprite2D.play("Reload")

func _melee_attack():
	print("smack")
	m_target_state = E_TARGET_STATE.MELEE
	m_move_timer.stop()
	m_attack_timer.stop()
	$AnimatedSprite2D.play("Melee")

func _hide():
	pass

func _retreat():
	pass

func _chase():
	pass

func _aim():
	m_attack_vector = m_last_hit_vector.normalized()
	if m_attack_vector.x != 0:
		if m_attack_vector.x > 0:
			if !m_left_face:
				_turn_around()
		else: 
			if m_left_face:
				_turn_around()
	if _find_player():
		_start_attack()
	else:
		_continue_patrol()

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
	var x = -patrol_radius if _is_left_of(m_origin) else patrol_radius
	_set_destination_update_origin(Vector2(position.x + x, position.y))

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

func _set_face_detection_enabled(enabled:bool):
	$CollisionCast.enabled = enabled

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

func _find_player():
	if !_facing_player():
		return false
	else:
		return $PlayerSearch.get_collider() != null && $PlayerSearch.get_collider().name == Strings.PlayerNodeName	

func _target_found():
	_attack()

func _target_lost():
	_start_patrol()

func _facing_player():
	if m_left_face:
		return position.x > GameManager.player.position.x
	else:
		return position.x < GameManager.player.position.x

func _can_melee():
	var collided = $CollisionCast.get_collider()
	if collided == null: 
		return false
	var name_string = collided.name
	$CollisionCast.force_raycast_update()
	return name_string == Strings.PlayerNodeName

#runtime
var m_origin:Vector2
var m_destination:Vector2
var m_last_hit_vector:Vector2
var m_attack_vector:Vector2
var m_current_charge:int = attacks_between_charge
var m_attack_timer
var m_move_timer
#compile
const DESTINATION_TOLERANCE:int = 30 #pixels


