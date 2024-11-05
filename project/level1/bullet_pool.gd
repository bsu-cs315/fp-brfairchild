extends Node2D

@export var bullet_scene: PackedScene
@export var pool_size: int = 20
var bullets: Array[Node2D] = []


func _ready():
	for i in range(pool_size):
		if bullet_scene:
			var bullet: Node2D = bullet_scene.instantiate() as Node2D
			bullet.visible = false
			add_child(bullet)
			bullet.bullet_pool = self
			bullets.append(bullet)


func spawn_bullet(spawn_position: Vector2):
	var player_position = get_closest_player_position(spawn_position)
	
	if player_position == null:
		return
	var direction = (player_position - spawn_position).normalized()
	for bullet in bullets:
		if !bullet.visible:
			bullet.position = spawn_position
			bullet.direction = direction
			bullet.visible = true
			break


func return_bullet(bullet: Node2D):
	bullet.reset_bullet()


func get_closest_player_position(spawn_position: Vector2) -> Vector2:
	var closest_player_position: Vector2 = Vector2.ZERO
	var closest_distance = INF
	var player_found = false

	for player in get_tree().get_nodes_in_group("player"):
		var distance = spawn_position.distance_to(player.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_player_position = player.global_position
			player_found = true
	return closest_player_position if player_found else Vector2.ZERO
