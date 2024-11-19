extends Node2D

@export var bullet_scene: PackedScene


func _on_spawn_1_timer_timeout() -> void:
	if bullet_scene:
		var bullet_instance = bullet_scene.instantiate()
		var bullet_instance2 = bullet_scene.instantiate()
		bullet_instance.position = $Spawn1.position
		bullet_instance2.position = $Spawn1b.position
		get_parent().add_child(bullet_instance)
		get_parent().add_child(bullet_instance2)
		

func _on_spawn_2_timer_timeout() -> void:
	var bullet_instance3 = bullet_scene.instantiate()
	var bullet_instance4 = bullet_scene.instantiate()
	bullet_instance3.position = $Spawn3.position
	bullet_instance4.position = $Spawn3b.position
	get_parent().add_child(bullet_instance3)
	get_parent().add_child(bullet_instance4)


func _on_spawn_3_timer_timeout() -> void:
	var bullet_instance5 = bullet_scene.instantiate()
	var bullet_instance6 = bullet_scene.instantiate()
	bullet_instance5.position = $Spawn2.position
	bullet_instance6.position = $Spawn2b.position
	get_parent().add_child(bullet_instance5)
	get_parent().add_child(bullet_instance6)
	
