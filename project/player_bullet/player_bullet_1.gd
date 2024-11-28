extends Area2D

@export var speed: float = 1500
@export var direction: Vector2 = Vector2(1, 0)

signal bullet_hit

func _process(delta: float):
	position += direction * speed * delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_character"):
		bullet_hit.emit(self)
