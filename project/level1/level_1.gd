extends Node2D

@export var Enemy: PackedScene
@onready var respawn_timer = $SpawnTimer


func _ready():
	spawn_enemies()


func spawn_enemies():
	var enemy_count = randi() % 6 + 3
	for i in range(enemy_count):
		var random_y = randf_range(0, 710)
		var enemy = Enemy.instantiate()
		enemy.position = Vector2(1280, random_y)
		enemy.connect("deleted", Callable(self, "_on_enemy_destroyed"))
		add_child(enemy)

func _on_enemy_destroyed():
	if get_tree().get_nodes_in_group("enemies").size() == 0:
		respawn_timer.start()

func _on_respawn_timer_timeout():
	spawn_enemies()