extends Node2D

@export var bullet_pool: Node


func _on_timer_timeout() -> void:
	if bullet_pool:
		var bullet_position = position
		bullet_pool.spawn_bullet(bullet_position)
	else:
		print("Bullet pool not assigned.")
