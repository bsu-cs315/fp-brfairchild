extends Node2D


func _on_Button_pressed():
	get_tree().change_scene_to_file("res://level1/level1.tscn")


func _on_how_to_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://how_to_play/how_to_play.tscn")
