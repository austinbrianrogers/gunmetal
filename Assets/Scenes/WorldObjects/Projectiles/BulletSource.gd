extends Node2D

@export var left:bool
const PROJECTILE_SOURCE = "res://Assets/Scenes/WorldObjects/Projectile/projectile.tscn"
const DEFAULT_VELOCITY:int = 500
# Called when the node enters the scene tree for the first time.
func _ready():
	m_projectile = preload(PROJECTILE_SOURCE)
	pass # Replace with function body.

func _fire(right:bool):
	var actual = DEFAULT_VELOCITY
	if !right: 
		actual = -(DEFAULT_VELOCITY)
	var bullet = m_projectile.instantiate()
	add_child(bullet)
	var root = get_tree().get_root()
	bullet.reparent(root, true)
	(bullet as RigidBody2D).add_constant_central_force(Vector2(actual, 0))
	pass

var m_projectile
