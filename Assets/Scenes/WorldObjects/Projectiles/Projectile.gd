extends RigidBody2D

#repeat values
const RIGHT = 1
const LEFT = -1
#compile variables
var run_max:float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	run_start = 0
	runtime = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_flip_for_direction(linear_velocity.x < 0)
	runtime += delta
	if(runtime > run_max):
		print("bye")
		queue_free()
	pass

func _flip_for_direction(left:bool):
	if left && !_is_facing_left():
		left_face = true
		scale = Vector2(LEFT, 1)
	else: if !left && _is_facing_left():
		left_face = false
		scale = Vector2(RIGHT, 1)
	pass

func _is_facing_left():
	return scale.x < 0
#runtime variables
var left_face:bool = false
var run_start:float
var runtime:float


