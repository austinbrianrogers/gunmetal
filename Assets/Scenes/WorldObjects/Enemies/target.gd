extends RigidBody2D
#editable
@export var health_points:int
#compile vars
const ALIVE = -1 
func _ready():
	$AnimatedSprite2D.play("Idle")
	m_current_health =  health_points

func _process(delta):
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


func _clean_up():
	await get_tree().create_timer(1).timeout
	queue_free()

func _is_dead():
	return m_time_of_death != ALIVE

#runtiume members
var m_current_health = 10
var m_time_of_death = ALIVE #default
#signals
signal died

