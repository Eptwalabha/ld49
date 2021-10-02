extends Node

var available_blocks = ["basic", "line", "tower"]

var BUILDING_BLOCKS = {
	"basic": preload("res://test/block/BasicBlock.tscn"),
	"line": preload("res://test/block/LineBlock.tscn"),
	"tower": preload("res://test/block/TowerBlock.tscn")
}
