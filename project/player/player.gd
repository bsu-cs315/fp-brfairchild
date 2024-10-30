extends CharacterBody2D

@export var speed: float = 425
@export var focus_speed: float = 175
@export var tilt_amount: float = 10.0


func _process(_delta: float):
	var direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	var current_speed = focus_speed if Input.is_action_pressed("focus") else speed
	velocity = direction * current_speed
	
	move_and_slide()
	
	if direction.y != 0:
		$AnimatedSprite2D.rotation_degrees = direction.y * tilt_amount
	else:
		$AnimatedSprite2D.rotation_degrees = lerp(float($AnimatedSprite2D.rotation_degrees), 0.0, 0.1)

	var screen_size = get_viewport_rect().size
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
