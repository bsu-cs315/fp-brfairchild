extends Node2D

@export var bullet_pool: Node
@export var speed_range: Vector2 = Vector2(100, 300)

@onready var act_bullet_pool = get_parent().get_node("BulletPool")

var health := 5
var speed: float

signal deleted
signal defeated


func _ready():
	speed = randf_range(speed_range.x, speed_range.y)
	bullet_pool = act_bullet_pool


func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -1:
		deleted.emit()
		queue_free()


func _on_timer_timeout() -> void:
	if bullet_pool:
		var bullet_position = position
		bullet_pool.spawn_bullet(bullet_position)
	else:
		print("Bullet pool not assigned.")


func _on_hitbox_area_entered(area: Area2D) -> void:
	$HitParticles.emitting = true
	if area.is_in_group("player_bullet"):
		health -= 1
		if health <= 0:
			deleted.emit()
			defeated.emit()
			queue_free()
