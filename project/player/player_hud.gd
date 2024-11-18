extends CanvasLayer

var player: Node = null


func _ready() -> void:
	player = find_node_recursive("Player")
	if player:
		player.connect("PLAYER_DIED", Callable(self, "_on_player_died"))
	else: pass





func find_node_recursive(target_name: String, root: Node = null) -> Node:
	if not root:
		root = get_tree().root
	for child in root.get_children():
		if child.name == target_name:
			return child
		var found = find_node_recursive(target_name, child)
		if found:
			return found
	return null


func _on_player_died() -> void:
	$HealthBar.value-=1
	print($HealthBar.value)
