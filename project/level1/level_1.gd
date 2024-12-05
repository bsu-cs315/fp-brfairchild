extends Node2D

@export var Enemy: PackedScene
@export var EnemyPhase2: PackedScene
@export var BulletPhase2: PackedScene
@export var boss: PackedScene
@export var player_scene: PackedScene
@onready var lose_button_animation_player = $LoseButton 

@onready var phase1_spawn_timer = $SpawnTimer
@onready var phase1_timer = $Phase1Timer
@onready var cooldown_timer = $CoolDownTImer
@onready var player_spawn = $PlayerSpawn 

var boss_spawned = false
var defeated_count: int = 0
var player_instance: CharacterBody2D = null

var player_lives: int = 3 


func _ready():
	phase1_timer.start()
	_respawn_player()
	spawn_enemies()
	player_instance.connect("PLAYER_DIED", Callable(self, "lose_life"))


func spawn_enemies():
	if not phase1_timer.is_stopped():
		var enemy_count = randi() % 6 + 3
		for i in range(enemy_count):
			var random_y = randf_range(0, 710)
			var enemy = Enemy.instantiate()
			enemy.position = Vector2(1280, random_y)
			enemy.connect("deleted", Callable(self, "_on_enemy_destroyed"))
			enemy.connect("defeated", Callable(self, "_on_enemy_defeated"))
			add_child(enemy)


func _on_enemy_destroyed():
	if get_tree().get_nodes_in_group("enemies").size() == 0:
		phase1_spawn_timer.start()


func _on_enemy_defeated():
	defeated_count += 1


func _on_phase_1_timer_timeout() -> void:
	phase1_spawn_timer.stop()
	cooldown_timer.start()


func _on_spawn_timer_timeout() -> void:
	if not phase1_timer.is_stopped():
		var enemy_count = randi() % 6 + 3
		for i in range(enemy_count):
			var random_y = randf_range(0, 710)
			var enemy = Enemy.instantiate()
			enemy.position = Vector2(1280, random_y)
			enemy.connect("deleted", Callable(self, "_on_enemy_destroyed"))
			enemy.connect("defeated", Callable(self, "_on_enemy_defeated"))
			add_child(enemy)


func _on_cool_down_timer_timeout() -> void:
	var enemy_instance = EnemyPhase2.instantiate()
	enemy_instance.position = Vector2.ZERO
	enemy_instance.connect("defeatedenm2", Callable(self, "_on_phase2_enemy_defeated")) 
	add_child(enemy_instance)

	var phase2_bullet = BulletPhase2.instantiate()
	add_child(phase2_bullet)


func _start_boss() -> void:
	if boss_spawned == false:
		var enemies = get_tree().get_nodes_in_group("enemy")
		for enemy in enemies:
			enemy.queue_free()
		var enemy_characters = get_tree().get_nodes_in_group("enemy_character")
		for enemy_character in enemy_characters:
			enemy_character.queue_free()
			
		boss_spawned = true
		call_deferred("_deferred_add_boss")
		$BossFx.visible = true
		$BossFx2.visible = true
	elif boss_spawned == true:
		return


func _deferred_add_boss():
	var bosss = boss.instantiate()
	add_child(bosss)
	bosss.connect("BOSS_DEFEATED", Callable(self, "_on_boss_defeated"))
	bosss._ready()


func _respawn_player():
	if player_instance:
		player_instance.queue_free()
	player_instance = player_scene.instantiate()
	player_instance.position = player_spawn.global_position
	player_instance.set_player_spawn(player_spawn)
	add_child(player_instance)


func _on_phase2_enemy_defeated():
	_start_boss()


func _on_phase_2_timer_timeout() -> void:
	_start_boss()


func _on_boss_defeated():
	$BossDeathSound.play()
	$WinTimer.start()


func lose_life():
	$PlayerDeathSound.play()
	player_lives -= 1
	if player_lives <= 0:
		play_lose_animation()


func play_lose_animation():
	lose_button_animation_player.play("try_again_button_anm")


func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://title/title.tscn")


func _on_win_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://win/win.tscn")
