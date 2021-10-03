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


func get_levels() -> Object:
	var dir : Directory = Directory.new()
	var all = {}
	var file_paths = []
	if dir.open("res://test/levels") == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			file_paths.push_back(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

	file_paths.sort()
	for i in range(len(file_paths)):
		var lvl_name = "lvl%s" % (i + 1)
		all[lvl_name] = {
			"path": "res://test/levels/%s" % file_paths[i],
			"completed": false,
		}
	return all

var levels = get_levels()

var current_level = "lvl1"
const SAVE_FILE_NAME = "ld49-unstable.save"

func save() -> bool:
	var save_file : File = File.new()
	if save_file.open("user://%s" % SAVE_FILE_NAME, File.WRITE) == OK:
		var save_data = {}
		for level in levels:
			save_data[level] = {
				"completed": levels[level].completed
			}
		save_file.store_line(to_json(save_data))
		save_file.close()
	return true

func load_save() -> void:
	var save_file : File = File.new()
	if !save_file.file_exists("user://%s" % SAVE_FILE_NAME):
		return
	if save_file.open("user://%s" % SAVE_FILE_NAME, File.READ) == OK:
		var data = parse_json(save_file.get_line())
		for line in data:
			levels[line].completed = data[line].completed
		save_file.close()

func erase_save() -> void:
	var dir : Directory = Directory.new()
	if dir.open("user://") == OK:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif file == SAVE_FILE_NAME:
				dir.remove(file)
		dir.list_dir_end()
