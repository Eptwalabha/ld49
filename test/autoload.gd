extends Node

var available_blocks = [
	"basic", "line", "tower",
	"plane-22", "plane-31", "plane-33", "plane-cross"
]

var BUILDING_BLOCKS = {
	"basic": preload("res://test/block/BasicBlock.tscn"),
	"line": preload("res://test/block/LineBlock.tscn"),
	"tower": preload("res://test/block/TowerBlock.tscn"),
	"plane-22": preload("res://test/block/planes/Plane2-2.tscn"),
	"plane-31": preload("res://test/block/planes/Plane3-1.tscn"),
	"plane-33": preload("res://test/block/planes/Plane3-3.tscn"),
	"plane-cross": preload("res://test/block/planes/PlaneCross.tscn")
}
