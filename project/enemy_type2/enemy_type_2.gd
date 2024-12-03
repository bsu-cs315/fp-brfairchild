extends Node2D

@export var bullet_scene: PackedScene

@warning_ignore("unused_signal")
# We can ignore this as it is being used by the level.
signal defeatedenm2

var health1 := 150
var health2 := 150

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

func _on_area_2_de_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		health1 -= 1
		if health1 <= 0:
			emit_signal("defeatedenm2")
			queue_free()

func _on_area_2_de_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		health2 -= 1
		if health2 <= 0:
			emit_signal("defeatedenm2")  
			queue_free()
