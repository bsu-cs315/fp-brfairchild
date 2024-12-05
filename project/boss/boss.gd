extends Node2D

@onready var phase_1_timer = $Phase1
@onready var phase_2_timer = $Phase2
@onready var bullet_scene = preload("res://boss/boss_bullet.tscn")
@onready var bullet_count = 8
@onready var spawn_loc = $BossSprite
@onready var bullet_timer = $BulletTimer
@onready var spawn_sound = $SpawnSound


var bullet_pool : Array = []
var active_bullets = []
var screen_rect : Rect2

var spin_speed = 1.0
var speed = 200
var max_bullets_in_pool = 250
var can_be_hurt = false
var boss_health = 700

signal BOSS_DEFEATED


func _ready() -> void:
	$AnimationPlayer.play("phase1")
	spin_speed = 0
	phase_1_timer.start()
	bullet_timer.start(0.8)
	screen_rect = Rect2(Vector2.ZERO, get_viewport().size)
	preload_bullet_pool()


func preload_bullet_pool() -> void:
	for i in range(max_bullets_in_pool):
		var bullet = bullet_scene.instantiate()
		bullet.visible = false
		add_child(bullet)
		bullet_pool.push_back(bullet)

func spawn_bullets_in_circle() -> void:
	var radius = 100
	var spawn_bullets = []
	var angle_step = 2 * PI / bullet_count

	for i in range(bullet_count):
		var angle = i * angle_step
		var cos_angle = cos(angle)
		var sin_angle = sin(angle)
		var bullet = get_inactive_bullet()

		if bullet:
			bullet.position = spawn_loc.position \
			+ Vector2(cos_angle * radius, sin_angle * radius)
			bullet.rotation = angle
			bullet.visible = true
			bullet.set_meta("initial_rotation", angle)
			bullet.set_meta("spinning", true)
			bullet.set_meta("moved", false)
			active_bullets.append(bullet)
			spawn_bullets.append(bullet)

	if spawn_bullets.size() > 0:
		spawn_sound.play()

	for bullet in spawn_bullets:
		bullet.set_meta("spinning", true)
		bullet.set_meta("moved", false)


func get_inactive_bullet() -> Node2D:
	if bullet_pool.size() > 0:
		return bullet_pool.pop_front()
	return null


func deactivate_bullet(bullet: Node2D) -> void:
	bullet.visible = false
	active_bullets.erase(bullet)
	bullet_pool.push_back(bullet)


func _on_phase_1_timeout() -> void:
	phase_2_timer.start()
	bullet_timer.start(0.2)
	
	$AnimationPlayer.play("phase2") 
	speed = 250
	start_spinning()


func _on_phase_2_timeout() -> void:
	$AnimationPlayer.stop()
	bullet_count = 15
	can_be_hurt = true
	$ProgressBar.visible = true
	$FinalTImer.start()


func _on_phase_1_bullet_timer_timeout() -> void:
	spawn_bullets_in_circle()


func _process(delta: float) -> void:
	for bullet in active_bullets:
		if is_instance_valid(bullet):
			var initial_rotation = bullet.get_meta("initial_rotation", 0)
			var spinning = bullet.get_meta("spinning", true)
			var moved = bullet.get_meta("moved", false)

			if spinning and not moved:
				var spin_amount = spin_speed * delta
				bullet.rotation += spin_amount
				bullet.position += Vector2(cos(bullet.rotation) \
				* speed * delta, sin(bullet.rotation) * speed * delta)

				if bullet.rotation >= initial_rotation + PI:
					bullet.set_meta("spinning", false)
					var random_direction = randf_range(0, 2 * PI)
					bullet.rotation = random_direction
					bullet.set_meta("random_direction", random_direction)
					bullet.set_meta("moved", true)
					
			if not spinning and moved:
				var random_direction = bullet.get_meta("random_direction", 0)
				bullet.position += Vector2(cos(random_direction) * speed \
				* delta, sin(random_direction) * speed * delta)

			if !screen_rect.has_point(bullet.position):
				deactivate_bullet(bullet)


func start_spinning() -> void:
	spin_speed = 2.0


func _on_final_t_imer_timeout() -> void:
	queue_free()


func _math_health() -> void:
	print($ProgressBar.value)

	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if can_be_hurt == true:
		if area.is_in_group("player_bullet"):
			boss_health -= 1
			$ProgressBar.value-=1
			_math_health()
			if boss_health <= 0:
				boss_death()
				
				
func boss_death() -> void:
	BOSS_DEFEATED.emit()
	queue_free()
