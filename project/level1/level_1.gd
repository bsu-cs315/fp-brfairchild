extends Node2D

@export var Enemy: PackedScene
@onready var phase1_spawn_timer = $SpawnTimer
@onready var phase1_timer = $Phase1Timer

@export var EnemyPhase2: PackedScene
@export var BulletPhase2: PackedScene

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
	$CoolDownTImer.start()

func _on_cool_down_timer_timeout() -> void:
	# Instantiate the Phase 2 enemy
	var enemy_instance = EnemyPhase2.instantiate()
	enemy_instance.position = Vector2.ZERO
	enemy_instance.connect("defeatedenm2", Callable(self, "_on_phase2_enemy_defeated"))  # Connect the defeated signal
	add_child(enemy_instance)

	# Instantiate the Phase 2 bullet
	var phase2_bullet = BulletPhase2.instantiate()
	phase2_bullet.speed = -500
	add_child(phase2_bullet)

func _start_boss() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.queue_free()
	var enemy_characters = get_tree().get_nodes_in_group("enemy_character")
	for enemy_character in enemy_characters:
		enemy_character.queue_free()

func _on_phase2_enemy_defeated():
	print("Phase 2 enemy defeated")
	_start_boss()  # Start the boss phase when the Phase 2 enemy is defeated
	
func _on_phase_2_timer_timeout() -> void:
	_start_boss()
