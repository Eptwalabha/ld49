class_name UIBlockPreview
extends Control

onready var block_preview : BlockPreview = $MarginContainer/ViewportContainer/Viewport/BlockPreview
onready var price : Label = $MarginContainer2/Label

func change_block_type(block_type: String) -> void:
	var block = GameData.BUILDING_BLOCKS[block_type].instance()
	block_preview.change_block(block)
	price.text = "$ %s" % block.price
