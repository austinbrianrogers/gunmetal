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

func _process(_delta):
	if !_is_dead():
		if !($AnimatedSprite2D.is_playing()):
			$AnimatedSprite2D.play("Idle")
	else:
		if (!$AnimatedSprite2D.is_playing()):
			_clean_up()

func _on_body_entered(body):
	if(_is_dead()): pass

	print("Ouch!")
	if body.get_collision_layer() == 2:
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

func _facing_left():
	if scale.x < 0:
		print("FACING LEFT, CAPTAIN")
	if scale.x > 0:
		print("FACING RIGHT, DICK")
	return scale.x < 0
	
func _turn_around():
	m_left_face = !m_left_face
	scale.x = -1
"""
It turns out that scale is always relative. Always. So if you turn the character around using scale -1,
you don't set it +1 to return to normal. You set the scale as -1 again._add_constant_central_force_add_constant_central_force
"""
func _moving():
	return velocity.x != 0
	


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
	WAITING
}
