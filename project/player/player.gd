extends CharacterBody2D

@export var speed := 650
@export var focus_speed := 175
@export var tilt_amount := 10.0
@export var bullet_scene: PackedScene
@export var bullet_offset := 80.0
@export var shoot_delay := 0.5  # Adjust the shooting delay here
@export var bullet_pool_size := 45

@onready var focus_sprite1 = $PlayerFocusTexture2
@onready var focus_sprite2 = $PlayerFocusTexture1
@onready var player_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var invTime = $GodTimer

var shoot_timer := 0.0
var bullet_pool: Array[Node2D] = []
var active_bullets: Array[Node2D] = []
var lives := 3
var invulnerable := false
var player_spawn: Node2D = null

signal PLAYER_DIED

func _ready():
	focus_sprite1.visible = false
	focus_sprite2.visible = false
	_initialize_bullet_pool()

func _initialize_bullet_pool():
	for i in range(bullet_pool_size):
		var bullet = bullet_scene.instantiate()
		bullet.visible = false
		bullet_pool.append(bullet)
		get_parent().call_deferred("add_child", bullet)
		bullet.connect("bullet_hit", Callable(self, "_on_bullet_collided"))

func _process(delta: float):
	shoot_timer -= delta  # Decrease shoot_timer each frame

	# Get movement direction
	var direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	# Adjust speed for focus mode
	var current_speed = focus_speed if Input.is_action_pressed("focus") else speed
	velocity = direction * current_speed

	# Handle sprite rotation based on movement
	if direction.y != 0:
		player_sprite.rotation_degrees = direction.y * tilt_amount
	else:
		player_sprite.rotation_degrees = lerp(float(player_sprite.rotation_degrees), 0.1, 0.1)

	# Ensure player stays within screen bounds, with a 20-pixel margin
	var screen_size = get_viewport_rect().size
	position.x = clamp(position.x, 35, screen_size.x - 20)
	position.y = clamp(position.y, 20, screen_size.y - 20)

	move_and_slide()

	# Handle focus input and toggle focus sprites visibility
	if Input.is_action_pressed("focus"):
		focus_sprite1.visible = true
		focus_sprite2.visible = true
	else:
		focus_sprite1.visible = false
		focus_sprite2.visible = false

	# Handle shooting input with delay
	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		$Bullet1Sound.play()
		spawn_bullet()
		shoot_timer = shoot_delay  # Reset the shoot timer

	# Recycle off-screen bullets before shooting new ones
	for bullet in active_bullets:
		if is_bullet_off_screen(bullet):
			recycle_bullet(bullet)

func spawn_bullet():
	if bullet_pool.size() > 0:
		var bullet = bullet_pool.pop_back()
		bullet.position = global_position + Vector2(bullet_offset, 0)
		bullet.visible = true
		active_bullets.append(bullet)

func _on_bullet_collided(bullet: Node2D):
	recycle_bullet(bullet)

func recycle_bullet(bullet: Node2D):
	bullet.visible = false
	bullet.position = Vector2(-1000, -1000)  # Move the bullet off-screen
	active_bullets.erase(bullet)
	bullet_pool.append(bullet)

func is_bullet_off_screen(bullet: Node2D) -> bool:
	# Check if the bullet's position is off the right side of the screen
	return bullet.position.x > 1285  # Adjust this value depending on your screen width

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and not invulnerable:
		lives -= 1
		PLAYER_DIED.emit()
		if lives > 0:
			respawn_at_player_spawn()
		else:
			queue_free()

func respawn_at_player_spawn():
	if player_spawn:
		global_position = player_spawn.global_position
		activate_invulnerability()
	else:
		print("Error: PlayerSpawn node not found!")

func set_player_spawn(spawn: Node2D):
	player_spawn = spawn

func activate_invulnerability() -> void:
	invulnerable = true
	invTime.start()
	print("Starting inv")
	call_deferred("_disable_collision_shape")

func _disable_collision_shape() -> void:
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func _enable_collision_shape() -> void:
	print("Stopping inv")
	if collision_shape:
		collision_shape.set_deferred("disabled", false)

func _on_god_timer_timeout() -> void:
	call_deferred("_enable_collision_shape")
	invulnerable = false
