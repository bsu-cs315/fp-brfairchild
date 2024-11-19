extends Area2D

var player_position: Vector2
@onready var move_timer = get_node("%ChaseTImer")
@onready var push_timer = get_node("%PushTimer")

@export var speed := 300
var can_move: bool = true

signal FINISH_PHASE2

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player_sprite")
	if players.size() > 0:
		player_position = players[0].position


func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player_sprite")
	if players.size() > 0:
		player_position = players[0].position
	if can_move and player_position:
		var direction = (player_position - position).normalized()
		position += direction * speed * delta


func _on_chase_timer_timeout() -> void:
	can_move = true


func stop_moving() -> void:
	can_move = false
	move_timer.start()


func _on_push_timer_timeout() -> void:
	stop_moving()


func _on_master_timer_timeout() -> void:
	FINISH_PHASE2.emit()
	queue_free()
