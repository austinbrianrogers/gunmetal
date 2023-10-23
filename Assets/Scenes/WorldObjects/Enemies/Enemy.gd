extends "res://Assets/Scenes/WorldObjects/Enemies/Target.gd"
#compile
@export var patrol_radius:float
@export var walk_speed:float
@export var wait_time_between_moves:float
func _ready():
	super()
	#_set_sleeping(false)
	_get_origin()
	_wait_and_choose_next()

func _physics_process(delta):
	velocity.y += delta * Maths.Gravity
	move_and_slide()

func _process(delta):
	super(delta)
	if m_target_state == E_TARGET_STATE.PATROLLING:
		if _reached_destination():
			_halt()
	pass

func _start_patrol():
	_turn_around()
	print("Starting patrol ")
	var vector = m_destination - position
	vector = vector.normalized()
	print("Direction is ", vector)
	velocity.x = vector.x * walk_speed
	print("Patrolling with velocity ", velocity)
	$AnimatedSprite2D.play("Walk")
	m_target_state = E_TARGET_STATE.PATROLLING

func _halt():
	print("Stopping")
	#_set_sleeping(true)
	velocity.x = 0
	m_target_state = E_TARGET_STATE.WAITING
	_wait_and_choose_next()
	$AnimatedSprite2D.play("Idle")

func _wait_and_choose_next():
	await get_tree().create_timer(wait_time_between_moves).timeout
	_choose_destination()
	_start_patrol()

func _attack():
	pass

func _hide():
	pass

func _retreat():
	pass

func _chase():
	pass

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
#compile
const DESTINATION_TOLERANCE:int = 1


