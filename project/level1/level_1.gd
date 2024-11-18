extends Node2D

@export var Enemy: PackedScene
@onready var phase1_spawn_timer = $SpawnTimer
@onready var phase1_timer = $Phase1Timer

var defeated_count: int = 0


func _ready():
	phase1_timer.start()
	spawn_enemies()


func spawn_enemies():
	if phase1_timer.is_stopped():
		return
	
	var enemy_count = randi() % 6 + 3
	for i in range(enemy_count):
		var random_y = randf_range(0, 710)
		var enemy = Enemy.instantiate()
		enemy.position = Vector2(1280, random_y)
		enemy.connect("deleted", Callable(self, "_on_enemy_destroyed"))
		enemy.connect("defeated", Callable(self, "_on_enemy_defeated"))
		add_child(enemy)


func _on_enemy_destroyed():
	if phase1_timer.is_stopped():
		return
	
	if get_tree().get_nodes_in_group("enemies").size() == 0:
		phase1_spawn_timer.start()


func _on_enemy_defeated():
	defeated_count += 1
	print("Enemies defeated:", defeated_count)


func _on_respawn_timer_timeout(): 
	spawn_enemies()


func _on_phase1_timeout() -> void:
	phase1_spawn_timer.stop()
	print("Level timer expired. No more enemies will spawn.")
