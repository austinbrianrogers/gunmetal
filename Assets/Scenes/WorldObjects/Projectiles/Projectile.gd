extends RigidBody2D

#repeat values
const RIGHT = 1
const LEFT = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	m_run_start = 0
	m_runtime = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_flip_for_direction(linear_velocity.x < 0)
	m_runtime += delta
	if(m_runtime > m_run_max):
		print("bye")
		queue_free()

func _flip_for_direction(left:bool):
	if left && !_is_facing_left():
		m_left_face = true
		scale = Vector2(LEFT, 1)
	else: if !left && _is_facing_left():
		m_left_face = false
		scale = Vector2(RIGHT, 1)

func _is_facing_left():
	return scale.x < 0

#runtime variables
var m_left_face:bool = false
var m_run_start:float
var m_runtime:float

#compile variables
var m_run_max:float = 1


