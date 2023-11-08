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
	m_runtime += delta
	if(m_runtime > m_run_max):
		queue_free()

func _impact(body):
	print("Body struck: ", body.get_collision_layer())
	var layers = body.get_collision_layer()
	if layers & (1 << Physics.Wall):
		_dismiss()
	if layers & (1 << Physics.Floor):
		_dismiss()

func _dismiss():
	queue_free()

#runtime variables
var m_left_face:bool = false
var m_run_start:float
var m_runtime:float

#compile variables
var m_run_max:float = 1


