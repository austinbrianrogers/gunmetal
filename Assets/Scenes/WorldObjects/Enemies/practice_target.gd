extends Area2D

func _ready():
	$AnimatedSprite2D.play("Idle")
	pass

func _process(delta):
	if !($AnimatedSprite2D.is_playing()):
		$AnimatedSprite2D.play("Idle")
	pass

func _on_body_entered(body):
	$AnimatedSprite2D.play("Hit")
	pass


