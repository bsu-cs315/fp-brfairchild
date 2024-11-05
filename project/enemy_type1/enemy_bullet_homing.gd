extends Node2D

@export var speed: float = 400.0
@export var turn_rate: float = 0.5
@export var max_curves: int = 500
var direction: Vector2
var bullet_pool: Node
var curve_attempts: int = 0
var tracking: bool = true


func _ready():
	curve_attempts = 0
	tracking = true


func _process(delta: float):
	if tracking:
		var player_position = bullet_pool.get_closest_player_position(position)
		if player_position != null:
			var target_direction = (player_position - position).normalized()
			direction = direction.lerp(target_direction, turn_rate)
			curve_attempts += 1
			if curve_attempts >= max_curves:
				tracking = false
	position += direction * speed * delta

	if is_out_of_bounds():
		if bullet_pool:
			bullet_pool.return_bullet(self)


func is_out_of_bounds() -> bool:
	var screen_size = get_viewport().size
	return position.x < 0 or position.x > screen_size.x or position.y < 0 or position.y > screen_size.y


func reset_bullet():
	position = Vector2.ZERO
	visible = false
	direction = Vector2(0, 0)
	curve_attempts = 0
	tracking = true
