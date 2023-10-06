extends Node2D

@export var left:bool
const _ProjectileSource = "res://Assets/Scenes/WorldObjects/Projectile/projectile.tscn"
const _DefaultVelocity:int = 500
# Called when the node enters the scene tree for the first time.
func _ready():
	projectile = preload(_ProjectileSource)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _fire(right:bool):
	var actual = _DefaultVelocity
	if !right: 
		actual = -(_DefaultVelocity)
	var bullet = projectile.instantiate()
	add_child(bullet)
	var root = get_tree().get_root()
	bullet.reparent(root, true)
	(bullet as RigidBody2D).add_constant_central_force(Vector2(actual, 0))
	pass

var projectile
