extends CharacterBody2D
#editable
@export var health_points:int
#compile vars
const ALIVE = -1 
const LEFT = -1
const RIGHT = 1
func _ready():
	$AnimatedSprite2D.play("Idle")
	m_current_health =  health_points
	m_left_face = false

func _process(_delta):
	if !_is_dead():
		if !($AnimatedSprite2D.is_playing()):
			$AnimatedSprite2D.play("Idle")
	else:
		if (!$AnimatedSprite2D.is_playing()):
			_clean_up()

func _physics_process(_delta):
	_correct_face()

func _correct_face():
	if velocity.x > 0 && m_left_face:
		_turn_around()
	else: if velocity.x < 0 && !m_left_face:
		_turn_around()

func _correct_face_to(vector:Vector2):
	if _is_left_of(vector) && m_left_face:
		_turn_around()
	else:if !_is_left_of(vector) && !m_left_face:
		_turn_around()

func _is_left_of(pos:Vector2):
	return (pos - position).x < 0

func _on_body_entered(body):
	if(_is_dead()): pass
#this is wrong, you need to code out the layer dependance and move it to the extensions
	print("Ouch!")
	match body.get_collision_layer():
		Physics.Projectile:
			$AnimatedSprite2D.play("Hit")
			_add_to_health(-1)
	#bullet can be deleted
	body.queue_free()

func _add_to_health(delta:int):
	m_current_health += delta
	if m_current_health <= 0:
		_die()

func _die():
	$AnimatedSprite2D.play("Die")
	m_time_of_death = Time.get_unix_time_from_system()
	died.emit()
	m_target_state = E_TARGET_STATE.DEAD

func _clean_up():
	await get_tree().create_timer(1).timeout
	queue_free()

func _is_dead():
	return m_time_of_death != ALIVE
	
func _turn_around():
	m_left_face = !m_left_face
	scale.x = -1
	print("flippy")
"""
It turns out that scale is always relative. Always. So if you turn the character around using scale -1,
you don't set it +1 to return to normal. You set the scale as -1 again._add_constant_central_force_add_constant_central_force
"""
func _is_moving():
	return velocity.x != 0

func _is_moving_left():
	return velocity.x < 0

func _is_moving_right():
	return velocity.x > 0

func _animating():
	return $AnimatedSprite2D.is_playing()

func _idle():
	velocity.x = 0
	$AnimatedSprite2D.play("Idle")

#runtiume members
var m_current_health
var m_time_of_death = ALIVE #default
var m_target_state:E_TARGET_STATE
var m_left_face = false
#signals
signal died
#utilities
enum E_TARGET_STATE {
	HALTED,
	PATROLLING,
	CHASING,
	DYING,
	DEAD,
	ATTACKING,
	HIDING,
	WAITING,
	HIT,
	CHARGING,
	PLAYER,
	IDLE,
	SEARCHING,
	MELEE
}
