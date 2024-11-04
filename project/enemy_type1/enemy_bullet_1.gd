extends Node2D

@export var speed: float = 400.0
var direction: Vector2
var bullet_pool: Node


func _ready():
	if bullet_pool:
		var player_position = bullet_pool.get_closest_player_position(position)
		if player_position != null:
			direction = (player_position - position).normalized()


func _process(delta: float):
	position += direction * speed * delta
	if direction.length() > 0:
		rotation = direction.angle() + PI

	if is_out_of_bounds():
		if bullet_pool:
			bullet_pool.return_bullet(self)


func is_out_of_bounds() -> bool:
	var screen_size = get_viewport().size
	return position.x < 0 or position.x > screen_size.x or position.y < 0 or position.y > screen_size.y


func reset_bullet():
	position = Vector2.ZERO
	visible = false
	direction = Vector2.ZERO
