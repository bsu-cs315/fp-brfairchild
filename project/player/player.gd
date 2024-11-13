extends CharacterBody2D

@export var speed := 650
@export var focus_speed := 175
@export var tilt_amount := 10.0
@export var bullet_scene: PackedScene
@export var bullet_offset := 80.0
@export var shoot_delay := 0.05
@export var bullet_pool_size := 45

@onready var focus_sprite1 = $PlayerFocusTexture2
@onready var focus_sprite2 = $PlayerFocusTexture1
@onready var player_sprite = $AnimatedSprite2D

var shoot_timer := 0.0
var bullet_pool: Array[Node2D] = [] 
var active_bullets: Array[Node2D] = []


func _ready():
	focus_sprite1.visible = false
	focus_sprite2.visible = false
	call_deferred("_initialize_bullet_pool")
	


func _initialize_bullet_pool():
	for i in bullet_pool_size:
		var bullet = bullet_scene.instantiate()
		bullet.visible = false
		bullet_pool.append(bullet)
		get_parent().add_child(bullet)
		bullet.connect("bullet_hit", Callable(self, "_on_bullet_collided"))
		


func _process(delta: float):
	shoot_timer -= delta
	var direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	var current_speed = focus_speed if Input.is_action_pressed("focus") else speed
	velocity = direction * current_speed
	
	if Input.is_action_pressed("focus"):
		focus_sprite1.visible = true
		focus_sprite2.visible = true
	else:
		focus_sprite1.visible = false
		focus_sprite2.visible = false
	move_and_slide()

	if direction.y != 0:
		player_sprite.rotation_degrees = direction.y * tilt_amount
	else:
		player_sprite.rotation_degrees = lerp(float(player_sprite.rotation_degrees), 0.0, 0.1)
		
	var screen_size = get_viewport_rect().size
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		$Bullet1Sound.play()
		spawn_bullet()
		shoot_timer = shoot_delay
		
	for bullet in active_bullets:
		if is_bullet_off_screen(bullet):
			recycle_bullet(bullet)


func spawn_bullet():
	if bullet_pool.size() > 0:
		var bullet = bullet_pool.pop_back()
		bullet.position = global_position + Vector2(bullet_offset, 0)
		bullet.visible = true
		active_bullets.append(bullet)
	else:
		pass

func _on_bullet_collided(bullet: Node2D):
	print("ow")
	recycle_bullet(bullet)


func recycle_bullet(bullet: Node2D):
	bullet.visible = false
	bullet.position = Vector2(-1000, -1000)
	active_bullets.erase(bullet)
	bullet_pool.append(bullet)


func is_bullet_off_screen(bullet: Node2D) -> bool:
	var screen_size = get_viewport_rect().size
	return (bullet.position.x < 0 or bullet.position.x > screen_size.x or
			bullet.position.y < 0 or bullet.position.y > screen_size.y)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		call_deferred("_change_scene")
		
func _change_scene():
	get_tree().change_scene_to_file("res://title/title.tscn")
	queue_free()
		
