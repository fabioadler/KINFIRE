class_name SkillTreeData
extends Resource
## Árvore de habilidades de uma classe (data-driven).
## Fica em res://data/trees/<classe>.tres

## Preload para type hint funcionar em parse time
const SkillNodeData := preload("res://scripts/data/skill_node_data.gd")

@export var class_id: StringName
@export var nodes: Array[SkillNodeData] = []


func get_node(node_id: StringName) -> SkillNodeData:
	for n in nodes:
		if n.id == node_id:
			return n
	return null


func get_available_nodes(unlocked: Array[StringName]) -> Array[SkillNodeData]:
	var available := []
	for n in nodes:
		if n.id in unlocked:
			continue
		if n.is_available(unlocked):
			available.append(n)
	return available


func get_node_dependencies(node_id: StringName) -> Array[StringName]:
	var node := get_node(node_id)
	if node:
		return node.requires.duplicate()
	return []


func get_dependent_nodes(node_id: StringName) -> Array[SkillNodeData]:
	var deps := []
	for n in nodes:
		if node_id in n.requires:
			deps.append(n)
	return deps