extends Area2D

@export var speed: float = 1050
@export var direction: Vector2 = Vector2(1, 0)

func _process(delta: float):
	position += direction * speed * delta
