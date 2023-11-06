extends Node2D

@export var left:bool
const PROJECTILE_SOURCE = "res://Assets/Scenes/WorldObjects/Projectile/projectile.tscn"
const DEFAULT_VELOCITY:int = 2600
# Called when the node enters the scene tree for the first time.
func _ready():
	m_projectile = preload(PROJECTILE_SOURCE)

func _fire(right:bool):
	var actual = DEFAULT_VELOCITY
	if !right: 
		actual = -(DEFAULT_VELOCITY)
	var bullet = m_projectile.instantiate()
	add_child(bullet)
	var root = get_tree().get_root()
	bullet.reparent(root, true)
	(bullet as RigidBody2D).linear_velocity = (Vector2(actual, 0))
	if actual < 0:
		bullet.scale *= -1
	#this particular thing is going to be used a lot and it would be good 
	#to have this become a base thing for the whole project that can be
	#called as a super. If you are reading this in the future, austin, you should
	#do this.

var m_projectile
