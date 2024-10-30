extends Area2D

@export var speed: float = 850
@export var direction: Vector2 = Vector2(1, 0)  # Initial direction, e.g., right

func _process(delta: float):
	# Move bullet in the set direction
	position += direction * speed * delta

	# Check if bullet is off-screen, then queue it for deletion
	var screen_size = get_viewport_rect().size
	if position.x < 0 or position.x > screen_size.x or position.y < 0 or position.y > screen_size.y:
		queue_free()
